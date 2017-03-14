#include <assert.h>
#include "btree.h"
#include <string.h>

KeyValuePair::KeyValuePair()
{
}

KeyValuePair::KeyValuePair(const KEY_T &k, const VALUE_T &v) : key(k), value(v)
{
}

KeyValuePair::KeyValuePair(const KeyValuePair &rhs) : key(rhs.key), value(rhs.value)
{
}

KeyValuePair::~KeyValuePair()
{
}

KeyValuePair &KeyValuePair::operator=(const KeyValuePair &rhs)
{
  return *(new (this) KeyValuePair(rhs));
}

BTreeIndex::BTreeIndex(SIZE_T keysize,
                       SIZE_T valuesize,
                       BufferCache *cache,
                       bool unique)
{
  superblock.info.keysize = keysize;
  superblock.info.valuesize = valuesize;
  buffercache = cache;
  // note: ignoring unique now
}

BTreeIndex::BTreeIndex()
{
  // shouldn't have to do anything
}

//
// Note, will not attach!
//
BTreeIndex::BTreeIndex(const BTreeIndex &rhs)
{
  buffercache = rhs.buffercache;
  superblock_index = rhs.superblock_index;
  superblock = rhs.superblock;
}

BTreeIndex::~BTreeIndex()
{
  // shouldn't have to do anything
}

BTreeIndex &BTreeIndex::operator=(const BTreeIndex &rhs)
{
  return *(new (this) BTreeIndex(rhs));
}

ERROR_T BTreeIndex::AllocateNode(SIZE_T &n)
{
  n = superblock.info.freelist;

  if (n == 0)
  {
    return ERROR_NOSPACE;
  }

  BTreeNode node;

  node.Unserialize(buffercache, n);

  assert(node.info.nodetype == BTREE_UNALLOCATED_BLOCK);

  superblock.info.freelist = node.info.freelist;

  superblock.Serialize(buffercache, superblock_index);

  buffercache->NotifyAllocateBlock(n);

  return ERROR_NOERROR;
}

ERROR_T BTreeIndex::DeallocateNode(const SIZE_T &n)
{
  BTreeNode node;

  node.Unserialize(buffercache, n);

  assert(node.info.nodetype != BTREE_UNALLOCATED_BLOCK);

  node.info.nodetype = BTREE_UNALLOCATED_BLOCK;

  node.info.freelist = superblock.info.freelist;

  node.Serialize(buffercache, n);

  superblock.info.freelist = n;

  superblock.Serialize(buffercache, superblock_index);

  buffercache->NotifyDeallocateBlock(n);

  return ERROR_NOERROR;
}

ERROR_T BTreeIndex::Attach(const SIZE_T initblock, const bool create)
{
  ERROR_T rc;

  superblock_index = initblock;
  assert(superblock_index == 0);

  if (create)
  {
    // build a super block, root node, and a free space list
    //
    // Superblock at superblock_index
    // root node at superblock_index+1
    // free space list for rest
    BTreeNode newsuperblock(BTREE_SUPERBLOCK,
                            superblock.info.keysize,
                            superblock.info.valuesize,
                            buffercache->GetBlockSize());
    newsuperblock.info.rootnode = superblock_index + 1;
    newsuperblock.info.freelist = superblock_index + 2;
    newsuperblock.info.numkeys = 0;

    buffercache->NotifyAllocateBlock(superblock_index);

    rc = newsuperblock.Serialize(buffercache, superblock_index);

    if (rc)
    {
      return rc;
    }

    BTreeNode newrootnode(BTREE_ROOT_NODE,
                          superblock.info.keysize,
                          superblock.info.valuesize,
                          buffercache->GetBlockSize());
    newrootnode.info.rootnode = superblock_index + 1;
    newrootnode.info.freelist = superblock_index + 2;
    newrootnode.info.numkeys = 0;

    buffercache->NotifyAllocateBlock(superblock_index + 1);

    rc = newrootnode.Serialize(buffercache, superblock_index + 1);

    if (rc)
    {
      return rc;
    }

    for (SIZE_T i = superblock_index + 2; i < buffercache->GetNumBlocks(); i++)
    {
      BTreeNode newfreenode(BTREE_UNALLOCATED_BLOCK,
                            superblock.info.keysize,
                            superblock.info.valuesize,
                            buffercache->GetBlockSize());
      newfreenode.info.rootnode = superblock_index + 1;
      newfreenode.info.freelist = ((i + 1) == buffercache->GetNumBlocks()) ? 0 : i + 1;

      rc = newfreenode.Serialize(buffercache, i);

      if (rc)
      {
        return rc;
      }
    }
  }

  // OK, now, mounting the btree is simply a matter of reading the superblock

  return superblock.Unserialize(buffercache, initblock);
}

ERROR_T BTreeIndex::Detach(SIZE_T &initblock)
{
  return superblock.Serialize(buffercache, superblock_index);
}

ERROR_T BTreeIndex::LookupOrUpdateInternal(const SIZE_T &node,
                                           const BTreeOp op,
                                           const KEY_T &key,
                                           VALUE_T &value)
{
  BTreeNode b;
  ERROR_T rc;
  SIZE_T offset;
  KEY_T testkey;
  SIZE_T ptr;

  rc = b.Unserialize(buffercache, node);

  if (rc != ERROR_NOERROR)
  {
    return rc;
  }

  switch (b.info.nodetype)
  {
  case BTREE_ROOT_NODE:
  case BTREE_INTERIOR_NODE:
    // Scan through key/ptr pairs
    //and recurse if possible
    for (offset = 0; offset < b.info.numkeys; offset++)
    {
      rc = b.GetKey(offset, testkey);
      if (rc)
      {
        return rc;
      }
      if (key < testkey || key == testkey)
      {
        // OK, so we now have the first key that's larger
        // so we need to recurse on the ptr immediately previous to
        // this one, if it exists
        rc = b.GetPtr(offset, ptr);
        if (rc)
        {
          return rc;
        }
        return LookupOrUpdateInternal(ptr, op, key, value);
      }
    }
    // if we got here, we need to go to the next pointer, if it exists
    if (b.info.numkeys > 0)
    {
      rc = b.GetPtr(b.info.numkeys, ptr);
      if (rc)
      {
        return rc;
      }
      return LookupOrUpdateInternal(ptr, op, key, value);
    }
    else
    {
      // There are no keys at all on this node, so nowhere to go
      return ERROR_NONEXISTENT;
    }
    break;
  case BTREE_LEAF_NODE:
    // Scan through keys looking for matching value
    for (offset = 0; offset < b.info.numkeys; offset++)
    {
      rc = b.GetKey(offset, testkey);
      if (rc)
      {
        return rc;
      }
      if (testkey == key)
      {
        if (op == BTREE_OP_LOOKUP)
        {
          return b.GetVal(offset, value);
        }
        else
        {
          // BTREE_OP_UPDATE
          // WRITE ME
          return ERROR_UNIMPL;
        }
      }
    }
    return ERROR_NONEXISTENT;
    break;
  default:
    // We can't be looking at anything other than a root, internal, or leaf
    return ERROR_INSANE;
    break;
  }

  return ERROR_INSANE;
}

static ERROR_T PrintNode(ostream &os, SIZE_T nodenum, BTreeNode &b, BTreeDisplayType dt)
{
  KEY_T key;
  VALUE_T value;
  SIZE_T ptr;
  SIZE_T offset;
  ERROR_T rc;
  unsigned i;

  if (dt == BTREE_DEPTH_DOT)
  {
    os << nodenum << " [ label=\"" << nodenum << ": ";
  }
  else if (dt == BTREE_DEPTH)
  {
    os << nodenum << ": ";
  }
  else
  {
  }

  switch (b.info.nodetype)
  {
  case BTREE_ROOT_NODE:
  case BTREE_INTERIOR_NODE:
    if (dt == BTREE_SORTED_KEYVAL)
    {
    }
    else
    {
      if (dt == BTREE_DEPTH_DOT)
      {
      }
      else
      {
        os << "Interior: ";
      }
      for (offset = 0; offset <= b.info.numkeys; offset++)
      {
        rc = b.GetPtr(offset, ptr);
        if (rc)
        {
          return rc;
        }
        os << "*" << ptr << " ";
        // Last pointer
        if (offset == b.info.numkeys)
          break;
        rc = b.GetKey(offset, key);
        if (rc)
        {
          return rc;
        }
        for (i = 0; i < b.info.keysize; i++)
        {
          os << key.data[i];
        }
        os << " ";
      }
    }
    break;
  case BTREE_LEAF_NODE:
    if (dt == BTREE_DEPTH_DOT || dt == BTREE_SORTED_KEYVAL)
    {
    }
    else
    {
      os << "Leaf: ";
    }
    for (offset = 0; offset < b.info.numkeys; offset++)
    {
      if (offset == 0)
      {
        // special case for first pointer
        rc = b.GetPtr(offset, ptr);
        if (rc)
        {
          return rc;
        }
        if (dt != BTREE_SORTED_KEYVAL)
        {
          os << "*" << ptr << " ";
        }
      }
      if (dt == BTREE_SORTED_KEYVAL)
      {
        os << "(";
      }
      rc = b.GetKey(offset, key);
      if (rc)
      {
        return rc;
      }
      for (i = 0; i < b.info.keysize; i++)
      {
        os << key.data[i];
      }
      if (dt == BTREE_SORTED_KEYVAL)
      {
        os << ",";
      }
      else
      {
        os << " ";
      }
      rc = b.GetVal(offset, value);
      if (rc)
      {
        return rc;
      }
      for (i = 0; i < b.info.valuesize; i++)
      {
        os << value.data[i];
      }
      if (dt == BTREE_SORTED_KEYVAL)
      {
        os << ")\n";
      }
      else
      {
        os << " ";
      }
    }
    break;
  default:
    if (dt == BTREE_DEPTH_DOT)
    {
      os << "Unknown(" << b.info.nodetype << ")";
    }
    else
    {
      os << "Unsupported Node Type " << b.info.nodetype;
    }
  }
  if (dt == BTREE_DEPTH_DOT)
  {
    os << "\" ]";
  }
  return ERROR_NOERROR;
}

ERROR_T BTreeIndex::Lookup(const KEY_T &key, VALUE_T &value)
{
  return LookupOrUpdateInternal(superblock.info.rootnode, BTREE_OP_LOOKUP, key, value);
}

ERROR_T BTreeIndex::Insert(const KEY_T &key, const VALUE_T &value)
{
  // WRITE ME
  // VALUE_T valueparam = value; //compiler won't accept a const
  SIZE_T new_node   = 0;
  KEY_T new_key     = 0;
  return InsertInternal(superblock.info.rootnode, key, value, new_node, new_key);
  // return ERROR_UNIMPL;
}

ERROR_T BTreeIndex::Split(const SIZE_T &node, SIZE_T &new_node,KEY_T &new_key){
    if (rc = b.Unserialize(buffercache,node)) return rc;
    BTreeNode rhs = BTreeNode(BTREE_INTERIOR_NODE, superblock.info.keysize,superblock.info.valuesize,superblock.info.blocksize);
    rc = AllocateNode(new_node);
    if (rc) return rc;
    SIZE_T temp_ptr, temp_key;
    SIZE_T split_ind = (b.info.numkeys+1)/2;
    rhs.info.numkeys = 0;


    for (int iter = 0; iter <= b.info.numkeys; iter ++){
        if (iter > split_ind){
            // get stuff to move over
            if (rc = b.GetPtr(iter, temp_ptr)) return rc;
            if (rc = b.GetKey(iter, temp_key)) return rc;                
            // zero lhs
            if (rc = b.SetPtr(iter, 0)) return rc;
            if (rc = b.SetKey(iter, 0)) return rc;
            // set stuff on rhs
            if (rc = rhs.SetPtr(iter-split_ind, temp_ptr)) return rc;
            if (rc = rhs.SetPtr(iter-split_ind, temp_key)) return rc;
            rhs.info.numkeys ++;
            b.info.numkeys --;
        }
    }
    // move the last pointer
    if (rc = b.GetPtr(iter + 1, temp_ptr)) return rc;
    if (rc = b.SetPtr(iter + 1, 0)) return rc;
    if (rc = rhs.SetPtr(iter+1-split_ind, temp_ptr)) return rc;
    rhs.info.numkeys ++;
    b.info.numkeys --;
}

ERROR_T BTreeIndex::split_leaf(const SIZE_T &node, SIZE_T &new_node,KEY_T &new_key){
    if (rc = b.Unserialize(buffercache,node)) return rc;
    BTreeNode rhs = BTreeNode(BTREE_LEAF_NODE, superblock.info.keysize,superblock.info.valuesize,superblock.info.blocksize);
    rc = AllocateNode(new_node);
    if (rc) return rc;
    SIZE_T temp_key, temp_val;
    SIZE_T split_ind = (b.info.numkeys+1)/2;
    rhs.info.numkeys = 0;

    for (int iter = 0; iter <= b.info.numkeys; iter ++){
        if (iter > split_ind){
            // get stuff to move over
            if (rc = b.GetVal(iter, temp_val)) return rc;
            if (rc = b.GetKey(iter, temp_key)) return rc;                
            // zero lhs
            if (rc = b.SetVal(iter, 0)) return rc;
            if (rc = b.SetKey(iter, 0)) return rc;
            // set stuff on rhs
            if (rc = rhs.SetVal(iter-split_ind, temp_val)) return rc;
            if (rc = rhs.SetVal(iter-split_ind, temp_key)) return rc;
            rhs.info.numkeys ++;
            b.info.numkeys --;
        }
    }
    // move the last pointer
    if (rc = b.GetVal(iter + 1, temp_val)) return rc;
    if (rc = b.SetVal(iter + 1, 0)) return rc;
    if (rc = rhs.SetVal(iter+1-split_ind, temp_val)) return rc;
    rhs.info.numkeys ++;
    b.info.numkeys --;
}



ERROR_T BTreeIndex::InsertInternal(const SIZE_T &node,
                                   const KEY_T &key,
                                   const &value,
                                   SIZE_T &new_node,
                                   KEY_T &new_key)
{
  BTreeNode b;
  ERROR_T rc;
  SIZE_T offset;
  KEY_T temp_key;
  SIZE_T temp_ptr;
  KEY_T lastKey;

  // unserialize
  if (rc = b.Unserialize(buffercache,node)) return rc;

  // switch
  switch (b.info.nodetype) {
    case BTREE_ROOT_NODE:
    case BTREE_INTERIOR_NODE:
      for (offset = 0;offset < b.info.numkeys; offset++) {
        if (rc = node.GetKey(offset, temp_key)) return rc;
        // if key is already in
        if (key == temp_key) {
          return ERROR_CONFLICT;
        } else if (key < temp_key ) {
          if (rc = b.GetPtr(offset, temp_ptr)) { return rc; }
          if (rc = InsertInternal(temp_ptr, key, value, new_node, new_key)) { return rc; }

          if (!new_node){
            return ERROR_NOERROR;

          } else if (new_node && b.info.numkeys < b.GetNumSlotsAsInterior()) {
            for (int shift_ind = offset; shift_ind < b.info.numkeys ; shift_ind ++){
              if (rc = b.GetPtr(shift_ind, temp_ptr)) return rc;
              if (rc = b.GetKey(shift_ind, temp_key)) return rc;

              if (rc = b.SetPtr(shift_ind+1, temp_ptr)) return rc;
              if (rc = b.SetKey(shift_ind+1, temp_key)) return rc;
            }
            if (rc = b.SetPtr(offset, new_node)) return rc;
            if (rc = b.SetKey(offset, new_key)) return rc;
            
            new_node = NULL;
            new_key = NULL;

            return b.Serialize(buffercache,node);
          
          } else if (new_node && b.info.numkeys == b.GetNumSlotsAsInterior()) { 
            split (node, new_node, new_key); // Node -> LHS, new_node -> Created RHS, new_key -> Same

            if (rc = new_node.GetKey(0, temp_key)) return rc;   

            bool inserted = false;
            //if inserting on left node
            if (temp_key > new_key){
              for (int offset = 0; offset < b.info.numkeys; offset++){
                  if (rc = b.GetKey(offset, temp_key)) return rc;
                  if (rc = b.GetPtr(offset, temp_ptr)) return rc;

                  if (temp_key > new_key){
                    if (!inserted) {
                      if (rc = b.SetPtr(offset, node)) return rc;
                      if (rc = b.SetKey(offset, new_key)) return rc;         
                      inserted = true;
                    }
                    if (rc = b.SetPtr(offset+1, temp_ptr)) return rc;
                    if (rc = b.SetKey(offset+1, temp_key)) return rc;
                  }
              }
              //if inserting on right node
            } else {
              for (int offset = 0; offset < rhs.info.numkeys; offset++){
                  if (rc = rhs.GetKey(offset, temp_key)) return rc;
                  if (rc = rhs.GetPtr(offset, temp_ptr)) return rc;

                  if (temp_key > new_key){
                    if (!inserted) {
                      if (rc = rhs.SetPtr(offset, node)) return rc;
                      if (rc = rhs.SetKey(offset, new_key)) return rc;         
                      inserted = true;
                    }
                    if (rc = rhs.SetPtr(offset+1, temp_ptr)) return rc;
                    if (rc = rhs.SetKey(offset+1, temp_key)) return rc;
                  }
              }
            }
            if (rc = rhs.GetKey(0, new_key)) return rc;
            if (rc = b.Serialize(buffercache, node)) return rc;
            if (rc = rhs.Serialize(buffercache, new_node)) return rc;

            //check if b root
            if (b.info.nodetype == BTREE_ROOT_NODE) {
              b.info.nodetype = BTREE_INTERIOR_NODE;
              BTreeNode new_root = BTreeNode(BTREE_ROOT_NODE,superblock.info.keysize,superblock.info.valuesize,superblock.info.blocksize);
              new_root.info.numkeys++;
              SIZE_T new_root_block;

              if (rc = AllocateNode(new_root_block)) return rc;
              if (rc = AllocateNode(new_node)) return rc;

              if (rc = new_root.SetKey(0,new_key);) { return rc; }
              if (rc = new_root.SetPtr(0, node)) { return rc; }
              if (rc = new_root.SetPtr(1, new_node)) { return rc; }
              
              if (rc = b.Serialize(buffercache, node)) return rc;
              if (rc = rhs.Serialize(buffercache, new_node)) return rc;
              if (rc = new_root.Serialize(buffercache, new_root_block)) return rc;

              superblock.info.rootnode = new_root_block;
              if (rc = superblock.Serialize(buffercache, superblock_index)) return rc;

              return ERROR_NOERROR;
            }
          }
        }
      }
        // try inserting in last slot
        if (rc = b.GetPtr(offset, temp_ptr)) { return rc; }
        if (rc = InsertInternal(temp_ptr, key, value, new_node, new_key)) { return rc; }
        if (new_node) {
            split (node, new_node, new_key); // Node -> LHS, new_node -> Created RHS, new_key -> Same
           
            if (rc = new_node.GetKey(0, temp_key)) return rc;   

            bool inserted = false;
            //if inserting on left node
            if (temp_key > new_key){
              for (int offset = 0; offset < b.info.numkeys; offset++){
                  if (rc = b.GetKey(offset, temp_key)) return rc;
                  if (rc = b.GetPtr(offset, temp_ptr)) return rc;

                  if (temp_key > new_key){
                    if (!inserted) {
                      if (rc = b.SetPtr(offset, node)) return rc;
                      if (rc = b.SetKey(offset, new_key)) return rc;         
                      inserted = true;
                    }
                    if (rc = b.SetPtr(offset+1, temp_ptr)) return rc;
                    if (rc = b.SetKey(offset+1, temp_key)) return rc;
                  }
                  b.info.numkeys ++;

              }
              //if inserting on right node
            } else {
              for (int offset = 0; offset < rhs.info.numkeys; offset++){
                  if (rc = rhs.GetKey(offset, temp_key)) return rc;
                  if (rc = rhs.GetPtr(offset, temp_ptr)) return rc;

                  if (temp_key > new_key){
                    if (!inserted) {
                      if (rc = rhs.SetPtr(offset, node)) return rc;
                      if (rc = rhs.SetKey(offset, new_key)) return rc;         
                      inserted = true;
                    }
                    if (rc = rhs.SetPtr(offset+1, temp_ptr)) return rc;
                    if (rc = rhs.SetKey(offset+1, temp_key)) return rc;
                  }
                }
                rhs.info.numkeys ++; 
            }
            if (rc = rhs.GetKey(0, new_key)) return rc;
            if (rc = b.Serialize(buffercache, node)) return rc;
            if (rc = rhs.Serialize(buffercache, new_node)) return rc;

            //check if b root
            if (b.info.nodetype == BTREE_ROOT_NODE) {
              b.info.nodetype = BTREE_INTERIOR_NODE;
              BTreeNode new_root = BTreeNode(BTREE_ROOT_NODE,superblock.info.keysize,superblock.info.valuesize,superblock.info.blocksize);
              new_root.info.numkeys++;
              SIZE_T new_root_block;

              if (rc = AllocateNode(new_root_block)) return rc;
              if (rc = AllocateNode(new_node)) return rc;

              if (rc = new_root.SetKey(0,new_key);) { return rc; }
              if (rc = new_root.SetPtr(0, node)) { return rc; }
              if (rc = new_root.SetPtr(1, new_node)) { return rc; }
              
              if (rc = b.Serialize(buffercache, node)) return rc;
              if (rc = rhs.Serialize(buffercache, new_node)) return rc;
              if (rc = new_root.Serialize(buffercache, new_root_block)) return rc;

              superblock.info.rootnode = new_root_block;
              if (rc = superblock.Serialize(buffercache, superblock_index)) return rc;

              return ERROR_NOERROR;
            }
          }
    case BTREE_LEAF_NODE:
      VALUE_T temp_val;
      if (b.info.numkeys < b.GetNumSlotsAsLeaf()){
        new_node = NULL;
        new_key = NULL;
        for (int offset = 0; offset < b.info.numkeys; offset++){
          if (rc = b.GetKey(offset, temp_key)) return rc;
          if (rc = b.GetVal(offset, temp_val)) return rc;

          if (temp_key > key){
            if (!inserted) {
              if (rc = b.SetVal(offset, value)) return rc;
              if (rc = b.SetKey(offset, key)) return rc;         
              inserted = true;
            }
            if (rc = b.SetVal(offset+1, temp_val)) return rc;
            if (rc = b.SetKey(offset+1, temp_key)) return rc;
          }
        }
        return ERROR_NOERROR;
      } else {
        split_leaf(node, new_node, new_key)
        if (rc = new_node.GetKey(0, new_key)) return rc;
        return ERROR_NOERROR;
      } 


  }

}

ERROR_T BTreeIndex::Update(const KEY_T &key, const VALUE_T &value)
{
  // WRITE ME
  return ERROR_UNIMPL;
}

ERROR_T BTreeIndex::Delete(const KEY_T &key)
{
  // This is optional extra credit
  //
  //
  return ERROR_UNIMPL;
}

//
//
// DEPTH first traversal
// DOT is Depth + DOT format
//

ERROR_T BTreeIndex::DisplayInternal(const SIZE_T &node,
                                    ostream &o,
                                    BTreeDisplayType display_type) const
{
  KEY_T testkey;
  SIZE_T ptr;
  BTreeNode b;
  ERROR_T rc;
  SIZE_T offset;

  rc = b.Unserialize(buffercache, node);

  if (rc != ERROR_NOERROR)
  {
    return rc;
  }

  rc = PrintNode(o, node, b, display_type);

  if (rc)
  {
    return rc;
  }

  if (display_type == BTREE_DEPTH_DOT)
  {
    o << ";";
  }

  if (display_type != BTREE_SORTED_KEYVAL)
  {
    o << endl;
  }

  switch (b.info.nodetype)
  {
  case BTREE_ROOT_NODE:
  case BTREE_INTERIOR_NODE:
    if (b.info.numkeys > 0)
    {
      for (offset = 0; offset <= b.info.numkeys; offset++)
      {
        rc = b.GetPtr(offset, ptr);
        if (rc)
        {
          return rc;
        }
        if (display_type == BTREE_DEPTH_DOT)
        {
          o << node << " -> " << ptr << ";\n";
        }
        rc = DisplayInternal(ptr, o, display_type);
        if (rc)
        {
          return rc;
        }
      }
    }
    return ERROR_NOERROR;
    break;
  case BTREE_LEAF_NODE:
    return ERROR_NOERROR;
    break;
  default:
    if (display_type == BTREE_DEPTH_DOT)
    {
    }
    else
    {
      o << "Unsupported Node Type " << b.info.nodetype;
    }
    return ERROR_INSANE;
  }

  return ERROR_NOERROR;
}

ERROR_T BTreeIndex::Display(ostream &o, BTreeDisplayType display_type) const
{
  ERROR_T rc;
  if (display_type == BTREE_DEPTH_DOT)
  {
    o << "digraph tree { \n";
  }
  rc = DisplayInternal(superblock.info.rootnode, o, display_type);
  if (display_type == BTREE_DEPTH_DOT)
  {
    o << "}\n";
  }
  return ERROR_NOERROR;
}

ERROR_T BTreeIndex::SanityCheck() const
{
  // WRITE ME
  return ERROR_UNIMPL;
}

ostream &BTreeIndex::Print(ostream &os) const
{
  // WRITE ME
  return os;
}

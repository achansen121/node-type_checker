
assert=require 'assert'

o={}

type_str={}
type_str.string=typeof ""
type_str.number=typeof 1
type_str.function=typeof (()->return)
type_str.object=typeof ({})
type_str.undefined=typeof undefined
type_str.boolean=typeof true

gen_type_enf=(ts,tk)->
  (a)->
    assert(arguments.length==1,"Wrong number of arguments")
    assert(typeof a==ts,"Not of type "+tk)
    return a

for tk,ts of type_str
  o[tk]=gen_type_enf(ts,tk)

o.object=(a)->
  assert(arguments.length==1,"Wrong number of arguments")
  assert(type_str.object==typeof a,"Not type object")
  assert(a!=null,"Null object")
  return a
  
o.number=(a)->
  assert(arguments.length==1,"Wrong number of arguments")
  assert(type_str.number==typeof a,"Not type number")
  o.not_nan(a)
  return a

o.not_nan=(a)->
  assert(arguments.length==1,"Wrong number of arguments")
  assert(!isNaN(a),"NaN number")
  return a

o.null=(a)->
  assert(arguments.length==1,"Wrong number of arguments")
  assert(a==null,"not null")
  return a

o.define_interface=(interface_def, sub_interface_defs)->
  assert(arguments.length>0,"Wrong number of arguments")
  assert(arguments.length<3,"Wrong number of arguments")
  interface_obj={type:"interface",required_keys:{}}
  for k,cobj of interface_def
    interface_obj.required_keys[k]=typeof cobj
  if sub_interface_defs?
    o.object(sub_interface_defs)
    for k,sint of sub_interface_defs
      o.undefined(interface_obj.required_keys[k])
      try
        o.is_valid_interface(sint)
      catch e
        throw new Error("invalid interface")
      interface_obj.required_keys[k]=sint
  return interface_obj
  

o.is_valid_interface=(iobj)->
  assert(arguments.length==1,"Wrong number of arguments")
  o.object(iobj)
  o.string(iobj.type)
  o.object(iobj.required_keys)
  assert(Object.keys(iobj).length==2)
  assert(iobj.type=="interface")
  for k,v of iobj.required_keys
    if typeof v==type_str.string
      continue
    if is_valid_interface(v)
      continue
    throw new Error("invalid interface value at key "+k)
  return true
    
o.coerce_number=(s)->
  assert(arguments.length==1,"Wrong number of arguments")
  if typeof s==type_str.number
    o.number(s)
    return s
  else if typeof s==type_str.string
    s=parseFloat(s)
    o.number(s)
  else
    throw new Error("could not coerce")
  return s
  

o.coerce_string=(s)->
  assert(arguments.length==1,"Wrong number of arguments")
  if typeof s==type_str.number
    s=s+""
  else if typeof s==type_str.object
    s=JSON.stringify(s)
  o.string(s)
  return s
  

o.uses_interface=(to_test,interface_obj)->
  assert(arguments.length==2,"Wrong number of arguments")
  o.object(to_test)
  try
    o.is_valid_interface(interface_obj)
  catch e
    throw new Error("Invalid interface: "+e)
  
  for k,v of interface_obj.required_keys
    if typeof v is type_str.string
      assert(typeof to_test[k]==v,"Invalid Type for key: "+k)
    else if typeof v is type_str.object
      is_valid_interface(v)
      o.uses_interface(to_test[k],v)
    else
      throw new Error("invalid interface def")
  return true;
  
  




module.exports=o
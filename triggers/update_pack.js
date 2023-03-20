var url, packs_table, pack_row;

function assert(check, error) {
  //console.log("assert(", check, ", ", error, ")");
  if(!check) {
    //console.error("assert: throw ", error);
    throw error;
  }
}

try {
  body = row || body;
} catch(e) {}

assert(!!(body && body.name && (body.url || body.pack)), "Payload must contains name and pack in pack or url forms.");
if(body.url) {
  assert(!body.pack, "Can't include pack in both pack and url form.");
  url = body.url;
  if(url.startsWith('/')) {
    url = (body.protocol?body.protocol:'http')+'://'+([req.ips,[req.ip]].flat()[0])+(body.port?':'+String(body.port):'')+url;
  }
  body.pack = await fetchJSON(url, {method: 'GET'});
}
packs_table = Table.findOne({name: 'packs'});
pack_row = await packs_table.getRow({name: body.name});
if(pack_row && pack_row.id)
  return await packs_table.tryUpdateRow({pack:body.pack,description:body.description?body.description:pack_row.description}, pack_row.id);
else
  return await packs_table.tryInsertRow({name:body.name,pack:body.pack,description:body.description});

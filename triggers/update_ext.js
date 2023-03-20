var url, plugin, ext_table, ext_row;

function assert(check, error) {
  //console.log("assert(", check, ", ", error, ")");
  if(!check) {
    //console.error("assert: throw ", error);
    throw error;
  }
}

function check_plugin(data) {
  return data && data.name && data.source && data.source in {"npm":0,"git":0,"github":0} && data.location;
}
function plugin_data({name, source, location, description, documentation_link}) {
  return {name, source, location, description, documentation_link};
}

try {
  body = row || body;
} catch(e) {}

assert(!!(body && (body.url || check_plugin(body.plugin) || check_plugin(body))), "Payload must contains url or plugin data.");
if(body.url) {
  assert(!body.pack, "Can't include pack in both pack and url form.");
  url = body.url;
  if(url.startsWith('/')) {
    url = (body.protocol?body.protocol:'http')+'://'+([req.ips,[req.ip]].flat()[0])+(body.port?':'+String(body.port):'')+url;
  }
  plugin = plugin_data(await fetchJSON(url, {method: 'GET'}));
} else if(check_plugin(body.plugin)) {
  plugin = plugin_data(body.plugin);
} else {
  plugin = plugin_data(body);
}
//console.log("plugin =", plugin);
ext_table = Table.findOne({name: 'extensions'});
ext_row = await ext_table.getRow({name: plugin.name});
if(ext_row && ext_row.id)
  return await ext_table.tryUpdateRow(Object.assign(ext_row, plugin), ext_row.id);
else {
  plugin.downloads = 0;
  return await ext_table.tryInsertRow(plugin);
}

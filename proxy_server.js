var http = require('http'),
    httpProxy = require('http-proxy');
//
// Setup our server to proxy standard HTTP requests
//
var proxy = new httpProxy.createProxyServer({
  target: {
    host: 'localhost',
    port: 9015
  }
});
var proxyServer = http.createServer(function (req, res) {
  proxy.web(req, res, { target: 'http://localhost:2000' });
});

//
// Listen to the `upgrade` event and proxy the
// WebSocket requests as well.
//
proxyServer.on('upgrade', function (req, socket, head) {
  proxy.ws(req, socket, { target: 'http://192.168.0.103:8000' });
});

proxyServer.listen(8080);
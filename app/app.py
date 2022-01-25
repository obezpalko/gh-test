#!/app/env/bin/python
import http.server
import logging
import socket
from os import environ
from threading import Thread

from kubernetes import client
from kubernetes import config


logging.basicConfig(
    format='%(asctime)s %(levelname)s: %(message)s',
    level=logging.DEBUG,
)


class AppHTTPHandler(http.server.BaseHTTPRequestHandler):
    """ customized http handler"""

    def _set_response(self, content_type: str = 'text/html'):
        self.send_response(200)
        self.send_header('Content-type', content_type)
        self.end_headers()

    def do_GET(self):
        """ manage get requests """
        content_type = 'text/plain'
        if self.path == '/pods':
            response = get_all_pods()
        elif self.path == '/me':
            response = socket.gethostbyname(socket.gethostname())
        elif self.path == '/health':
            env = environ.get('ENV', False)
            response = f'OK {env}' if env else 'OK'
        else:
            response = ''

        self._set_response(content_type)
        if isinstance(response, str):
            response = response.encode('utf-8')
        self.wfile.write(response)


def run_http_server(server_class=http.server.HTTPServer, handler_class=AppHTTPHandler):
    """ run http server """
    port = int(environ.get('SERVER_PORT', 8080))
    logging.debug('going to start http server')
    server_address = ('', port)
    server = server_class(server_address, handler_class)
    tread = Thread(target=server.serve_forever, daemon=False)
    tread.start()
    logging.info(
        'http server started on %s:%s',
        socket.gethostbyname(socket.gethostname()), port,
    )


def get_all_pods():
    config.load_incluster_config()
    v1 = client.CoreV1Api()
    logging.info('getting all pods')
    ret = v1.list_pod_for_all_namespaces(watch=False)
    return '\n'.join(
        [
            f'{i.status.pod_ip}\t{i.metadata.namespace}\t{i.metadata.name}'
            for i in ret.items
        ],
    )


if __name__ == '__main__':
    run_http_server()

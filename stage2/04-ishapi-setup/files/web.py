import BaseHTTPServer, SimpleHTTPServer
import ssl
import tempfile
import os
import AESCipher
import mycerts
import threading
import time
from urlparse import urlparse, parse_qs
import json
import subprocess


aes = AESCipher.AESCipher('Content-type: text/json') # Guess what's this? :-)
server_crt_file = tempfile.NamedTemporaryFile(dir="/tmp", delete=True)
server_crt_file.write(aes.decrypt(mycerts.server_crt))
server_crt_file.flush()

server_key_file = tempfile.NamedTemporaryFile(dir="/tmp", delete=True)
server_key_file.write(aes.decrypt(mycerts.server_key))
server_key_file.flush()

client_list_file = tempfile.NamedTemporaryFile(dir="/tmp", delete=True)
client_list_file.write(aes.decrypt(mycerts.client_list_crt))
client_list_file.flush()

globs = {}

class WebServer(BaseHTTPServer.BaseHTTPRequestHandler, object):

    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def _handle_input(self):
        self._who = "local"
        self._ip = self.client_address[0]
        if hasattr(self.connection, 'getpeercert'):
            self._who = self.connection.getpeercert()['subject'][3][0][1]
        self._query = parse_qs(urlparse(self.path).query)
        for k in self._query:
            if type(self._query[k]) is list and len(self._query[k]) == 1:
                self._query[k] = self._query[k][0]
        self._path = urlparse(self.path).path

        # Try content-length
        self._post_data = ''
        self._post_obj = {}
        if 'content-length' in self.headers:
            content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
            self._post_data = self.rfile.read(content_length)
            try:
                obj = json.loads(self._post_data)
                if 'enc' in obj:
                    self._post_obj = json.loads(aes.decrypt(obj['enc']))
            except Exception as ex:
                print "Exception: %s" % (ex)

    def _ok_resp(self, msg):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok", "message": msg}))

    def _error_resp(self, code, error=""):
        self.send_response(code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "error", "error": error}))

    def do_GET(self):
        self._handle_input()
        print "%s %s %s %s %s" % (self._post_data, self._query, self._path, self._who, self._post_obj)

        if self._path == '/getkey' and self._ip == "127.0.0.1" and 'key' in self._query:
            if self._query['key'] in globs:
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write(globs[self._query['key']])
                return

        self._error_resp(404)

    def do_POST(self):
        self._handle_input()
        #print "%s %s %s %s %s" % (self._post_data, self._query, self._path, self._who, self._post_obj)

        if self._path == '/connect':
            if len(self._post_obj) == 0:
                return self._error_resp(500, "No credentials provided")
            for k in self._post_obj:
                globs[k] = self._post_obj[k]
            return self._ok_resp()

        if self._path == '/ssh_connect':
            if 'ssh_key' not in self._post_obj:
                return self._error_resp(500, "No credentials provided")
            globs['ssh_key'] = self._post_obj['ssh_key']
            try:
                out = subprocess.check_output("sudo systemctl start ssh", shell=True)
                return self._ok_resp(out)
            except Exception as ex:
                return self._error_resp(500, str(ex))

        if self._path == '/encrypt_connect':
            if len(self._post_obj) == 0:
                return self._error_resp(500, "No credentials provided")
            for k in self._post_obj:
                globs[k] = self._post_obj[k]
            return self._ok_resp()

        return self._error_resp(404)

def serve_forever(httpd):
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()

def local_server(httpd):
    httpd.serve_forever()

def main():
    secure_httpd = BaseHTTPServer.HTTPServer(('0.0.0.0', 4443), WebServer)
    secure_httpd.socket = ssl.wrap_socket (secure_httpd.socket,
            certfile=server_crt_file.name,
            keyfile=server_key_file.name,
            server_side=True,
            cert_reqs=ssl.CERT_REQUIRED, ca_certs=client_list_file.name)
    secure_thread = threading.Thread(target=lambda: serve_forever(secure_httpd))
    secure_thread.start()

    local_httpd = BaseHTTPServer.HTTPServer(('0.0.0.0', 8080), WebServer)
    local_thread = threading.Thread(target=lambda: serve_forever(local_httpd))
    local_thread.start()

    try:
        while 1:
            time.sleep(10)
    except KeyboardInterrupt:
        print("Exiting")
        secure_httpd.shutdown()
        local_httpd.shutdown()
        secure_thread.join()
        local_thread.join()

main()

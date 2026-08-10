import http.server
import socketserver

PORT = 8002

class CrossOriginHeaderHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

with socketserver.TCPServer(("", PORT), CrossOriginHeaderHandler) as httpd:
    print(f"Serving Godot web build at http://localhost:{PORT}")
    httpd.serve_forever()
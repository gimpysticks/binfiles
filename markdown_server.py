#!/usr/bin/env python3
import http.server
import socketserver
import os
import markdown

PORT = 8000
MARKDOWN_FILE = "Home.md" # The exact, case-sensitive filename

class MarkdownHandler(http.server.SimpleHTTPRequestHandler):
    """
    A custom request handler that serves 'Home.md' as rendered HTML
    when the root path (/) is requested.
    """
    
    def do_GET(self):
        # Check if the request is for the root path ('/') or the exact file name
        if self.path == '/' or self.path == f'/{MARKDOWN_FILE}':
            try:
                # 1. Get the full, absolute path to the file
                file_path = os.path.join(os.getcwd(), MARKDOWN_FILE)

                # 2. Check specifically if the file exists and is a file (not a folder)
                if not os.path.isfile(file_path):
                    self.send_error(404, f"File Not Found: {MARKDOWN_FILE}")
                    return

                # 3. Read the Markdown content
                with open(file_path, 'r', encoding='utf-8') as f:
                    markdown_text = f.read()

                # 4. Convert Markdown to HTML
                html_content = markdown.markdown(markdown_text)
                
                # Wrap the content in a basic HTML page structure
                full_html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>{MARKDOWN_FILE}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {{ font-family: sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }}
    </style>
</head>
<body>
{html_content}
</body>
</html>
"""
                encoded_html = full_html.encode('utf-8')

                # 5. Send the HTTP response
                self.send_response(200)
                self.send_header("Content-type", "text/html; charset=utf-8")
                self.send_header("Content-Length", str(len(encoded_html)))
                self.end_headers()
                
                # 6. Write the HTML content to the connection
                self.wfile.write(encoded_html)
                
            except Exception as e:
                # Handle general exceptions during file serving/rendering
                print(f"Error serving file: {e}")
                self.send_error(500, "Internal Server Error")
        else:
            # For all other paths (like favicon.ico, images, or CSS files), 
            # use the default handler logic to serve static content.
            super().do_GET()

# --- Server Execution ---

if __name__ == "__main__":
    try:
        with socketserver.TCPServer(("", PORT), MarkdownHandler) as httpd:
            print(f"🚀 Serving {MARKDOWN_FILE} as rendered HTML at port {PORT}")
            print(f"Point your browser to http://localhost:{PORT}/")
            httpd.serve_forever()
    except OSError as e:
        if e.errno == 98:
            print(f"❌ Error: Port {PORT} is already in use. Please stop the other process or choose a different port.")
        else:
            raise
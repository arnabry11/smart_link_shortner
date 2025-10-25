require "api_docs"

class SwaggerController < ApplicationController
  def index
    if request.format.json?
      render json: ApiDocs.generate
    else
      render html: swagger_ui_html.html_safe
    end
  end

  private

  def swagger_ui_html
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Smart Link Shortener API Documentation</title>
        <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@3.25.0/swagger-ui.css" />
        <style>
          html {
            box-sizing: border-box;
            overflow: -moz-scrollbars-vertical;
            overflow-y: scroll;
          }
          *, *:before, *:after {
            box-sizing: inherit;
          }
          body {
            margin:0;
            background: #fafafa;
          }
        </style>
      </head>
      <body>
        <div id="token-manager" style="padding: 15px; background-color: #f8f9fa; border-bottom: 2px solid #007bff; position: sticky; top: 0; z-index: 1000;">
          <div style="max-width: 1200px; margin: 0 auto;">
            <h3 style="margin: 0 0 10px 0; color: #007bff;">JWT Token Manager</h3>
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
              <label for="jwt-token-input" style="font-weight: bold; white-space: nowrap;">JWT Token:</label>
              <input type="text" id="jwt-token-input" placeholder="Paste your JWT token here or login/register to auto-populate"
                     style="flex: 1; min-width: 300px; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-family: monospace; font-size: 12px;">
              <button id="save-token-btn" style="padding: 8px 15px; background-color: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;">Save Token</button>
              <button id="clear-token-btn" style="padding: 8px 15px; background-color: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer;">Clear Token</button>
              <span id="token-status" style="font-size: 12px; color: #666;"></span>
            </div>
          </div>
        </div>
        <div id="swagger-ui"></div>
        <script src="https://unpkg.com/swagger-ui-dist@3.25.0/swagger-ui-bundle.js"></script>
        <script src="https://unpkg.com/swagger-ui-dist@3.25.0/swagger-ui-standalone-preset.js"></script>
        <script>
          function updateTokenStatus() {
            const token = localStorage.getItem('jwt_token');
            const statusEl = document.getElementById('token-status');
            const inputEl = document.getElementById('jwt-token-input');

            if (token) {
              const truncatedToken = token.length > 20 ? token.substring(0, 20) + '...' : token;
              statusEl.textContent = `Active: ${truncatedToken}`;
              statusEl.style.color = '#28a745';
              inputEl.value = token;
            } else {
              statusEl.textContent = 'No token stored';
              statusEl.style.color = '#dc3545';
              inputEl.value = '';
            }
          }

          window.onload = function() {
            // Initialize token status
            updateTokenStatus();

            // Setup token management buttons
            document.getElementById('save-token-btn').onclick = function() {
              const token = document.getElementById('jwt-token-input').value.trim();
              if (token) {
                localStorage.setItem('jwt_token', token);
                updateTokenStatus();
                alert('Token saved! It will be automatically included in authenticated requests.');
              } else {
                alert('Please enter a token first.');
              }
            };

            document.getElementById('clear-token-btn').onclick = function() {
              localStorage.removeItem('jwt_token');
              updateTokenStatus();
              alert('Token cleared.');
            };

            const ui = SwaggerUIBundle({
              url: '/api-docs.json',
              dom_id: '#swagger-ui',
              deepLinking: true,
              presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIStandalonePreset
              ],
              plugins: [
                SwaggerUIBundle.plugins.DownloadUrl
              ],
              layout: "StandaloneLayout",
              // Enable request interceptor to handle JWT tokens
              requestInterceptor: function(req) {
                // Check if there's a stored token
                const token = localStorage.getItem('jwt_token');
                if (token && req.url.includes('/api/v1/') && !req.url.includes('/auth/login') && !req.url.includes('/auth/register') && !req.url.includes('/auth/forgot_password')) {
                  req.headers.Authorization = 'Bearer ' + token;
                }
                return req;
              },
              // Enable response interceptor to capture tokens from login/register responses
              responseInterceptor: function(res) {
                if ((res.url.includes('/auth/login') || res.url.includes('/auth/register')) && res.status === 200) {
                  try {
                    const responseBody = JSON.parse(res.text || res.data);
                    if (responseBody.token) {
                      localStorage.setItem('jwt_token', responseBody.token);
                      updateTokenStatus();
                      console.log('JWT token automatically saved from response');
                    }
                  } catch (e) {
                    console.log('Could not parse response for token extraction:', e);
                  }
                }
                return res;
              }
            });
          };
        </script>
      </body>
      </html>
    HTML
  end
end

# poppy_seeds

Nginx -> Lua -> Redis -> Rack -> Redis -> Lua -> Nginx

poppy_seeds reverse proxy using nginx+lua. It serializes all requests to Redis from where they are processed by workers.

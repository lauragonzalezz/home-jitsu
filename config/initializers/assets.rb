# Propshaft serves files from app/assets/* and app/assets/builds automatically.
# node_modules is not an asset path: Bootstrap and other packages are resolved
# at build time by sass/webpack (via --load-path), not served directly.

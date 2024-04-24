# Parts taken from: https://github.com/MathiasPius/kronform/blob/main/tools/entrypoint.sh
# MIT License

# Copyright (c) 2024 Mathias Pius

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Builds a "tools" container with most of the tools required
# to interact with the cluster and Kubernetes.
build:
    docker build -t tools:latest tools/
    
# Run the container, mounting in our SSH sops identities.
tools:
    docker run -it --rm                                 \
    -v $(pwd):/data                                     \
    -v /run/user/1000/:/run/user/1000/:ro               \
    -v $HOME/.config/sops:/home/user/.config/sops:ro    \
    tools:latest || true

# Render the template files.
render:
    (cd tools/ && makejinja)
Provision
=========

A general-purpose server provisioning script for Arch Linux systems. It is
intended for pedagogical use, but can be used in production (see warnings
below). It expects a clean install of Arch Linux and will configure:

- [nginx](http://wiki.nginx.org/Main), a static webserver
- [postgresql](http://www.postgresql.org/), a relational database
- [mongodb](http://www.mongodb.org/), a NoSQL database
- [redis](http://redis.io/), a key-value store
- [nodejs](http://nodejs.org/), for running node apps
- [rbenv](http://github.com/sstephenson/rbenv), for running ruby apps

It also installs some utilities, including [ssh](http://www.op enssh.com/),
[git](http://git-scm.com/), and [tmux](http://tmux.sourceforge.net/). You might
find it useful to look through if you haven't provisioned a server before.

There's some variables to set at the top of the script. Obviously you should
check it through as well.

**Security issue**: At the top of the script you're asked for a github
username. This is because we retrieve the SSH keys which have been authorised
to make changes to repos owned by that user, and use them to populate
`~deployer/.ssh/authorized_keys`. This means that any computer which can push
commits to repos owned by $GHUSER will be able to log in - without a password -
to your machine. This is cool if $GHUSER is you, but not so good otherwise.
Make sure it is!

The script also downloads config files (packaged as `home.tar` and `nginx.tar`)
from this repo. If you want it to install different config files, just host
your own tarballs somewhere are set the `$URL` to be the base URL - ie. the
tarballs should be hosted at `$URL/home.tar` and `$URL/nginx.tar`.


License
-------

> Copyright (c) 2012, Alex Sayers
> All rights reserved.
> 
> Redistribution and use in source and binary forms, with or without
> modification, are permitted provided that the following conditions are met: 
> 
> 1. Redistributions of source code must retain the above copyright notice, this
>    list of conditions and the following disclaimer. 
> 2. Redistributions in binary form must reproduce the above copyright notice,
>    this list of conditions and the following disclaimer in the documentation
>    and/or other materials provided with the distribution.
> 
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
> ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
> WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
> ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
> (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
> LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
> ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

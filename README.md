
A general-purpose server provisioning script for Arch Linux systems. It is intended to use used as a guide, and expects a clean install of Arch Linux. It will configure:

- [nginx](http://wiki.nginx.org/Main), a static webserver
- [postgresql](http://www.postgresql.org/), a relational database
- [mongodb](http://www.mongodb.org/), a NoSQL database
- [redis](http://redis.io/), a key-value store
- [nodejs](http://nodejs.org/), for running node apps
- [ruby](http://github.com/sstephenson/rbenv), for running rack apps

It also installs some utilities, including [ssh](http://www.op enssh.com/),
[git](http://git-scm.com/), and [tmux](http://tmux.sourceforge.net/). You might
find it useful to look through if you haven't provisioned a server before.

Please note the **serious security issue** introduced by running this script
as-is: `home.tar` contains a `.ssh/authorized_keys` file containing *my
personal public key*. If you run the script verbatim this gets copied into the
deployer user's home directory. If you do this, please rewrite
`authorized_keys` with your own public key.

If you intend to run this script, it is recommended that you fork it and modify
the files inside the `home` directory, updating the `$URL` variable to point to
the new location.


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

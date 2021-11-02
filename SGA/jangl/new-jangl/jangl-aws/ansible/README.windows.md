# Running Ansible from Windows

* Install Ubuntu 18.04 WSL distribution

* Create /etc/wsl.conf

  We need to override the default netmask for WSL automount.

    ```
    [automount]
    enabled = true
    mountFsTab = false
    # shorten up paths from /mnt/c to just /c/, matches windows -> docker machine mount semantics for better
    # WSL/docker interop.
    root = /
    # set metdata to enable chown/chmod in WSL
    # set default permissions for files without metadata perms.
    options = "metadata,umask=22,fmask=11"

    [network]
    generateHosts = true
    generateResolvConf = true
    ```


* SSH Agent

  * Use [KeePass + KeeAgent for keys with an msys compatible socket](https://github.com/dlech/KeeAgent/issues/159#issuecomment-409550658)

    configure msysGit compatible socket with path /c/Users/$USER/ssh-pageant.socket
  * copy .vscode/msysgit2unix-socket.py to ~/bin/

    ```bash
    # originally from
    # https://github.com/dlech/KeeAgent/issues/159#issuecomment-241193710
    # then https://gist.github.com/FlorinAsavoaie/8c2b6cb00f786c2caab65b1a51f4e847
    # and the version we're using https://gist.github.com/kevinvalk/3ccd5b360fd568862b4a397a9df9ed26
    cp .vscode/msysgit2unix-socket.py ~/bin
    chmod +x ~/bin/msysgit2unix-socket.py
    echo export SSH_AUTH_SOCK="/tmp/.ssh-auth-sock-keeagent" >> ~/.bashrc
    echo ~/bin/msysgit2unix-socket.py /c/Users/$USER/ssh-pageant.socket:$SSH_AUTH_SOCK >> ~/.bashrc

    . ~/.bashrc
    ```
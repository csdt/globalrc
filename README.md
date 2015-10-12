# What is GLOBALRC?
GLOBALRC is a set of scripts that allow you to easily export and import your configuration
from one to another.

The aim of this project is to synchronize your configuration
without the need to install anything into the machine,
and without deleting any existing configuration on the machine.

## How to use it?

### Export
Assuming you have install GLOBALRC on your local machine (localhost)
and you want to export your configuration onto a remote machine (example.com):

You just need to execute the following command:
```sh
pushrc example.com
```

Then, it is done! The script copied GLOBALRC onto the remote machine
and took care of adding lines to your current bashrc to include the conf.

### Import
It works exactly the same, but with the following command:
```sh
pullrc example.com
```

The remote user needs to already use GLOBALRC for importing.

### Customise
To customise GLOBALRC, it is extremely simple:
just modify existing files or creating new ones.
Everything inside the GLOBALRC dir is copied during synchronisation.

You should avoid modifying
`bashrc` `scripts/pullrc` `scripts/pushrc` `scripts/ssh` `scripts/scp`
`lib.sh/stream.sh` `lib.sh/sync.sh`
as these files are the core of GLOBALRC and modifying them can break GLOBALRC.

### Customise only for one machine
By default, when you export your configuration on a new machine, the script generates two folders:
- `~/.globalrc`: contains your configuration that will be exported to other machines (or imported from)
- `~/.localrc`: contains only local files that won't be exported nor imported,
and have the same structure than `~/.globalrc`

So everyting you put in `~/.localrc` will be load the same way your global conf but will stay on your local machine.

## How to install it?
### From Github
For the first time, you need to install it from Github.
The basic idea is to download it, and link it to your bashrc.

You can do the following commands to do it automatically:
```sh
#! /bin/sh
cd # go to your home
git clone https://github.com/csdt/globalrc.git .globalrc # clone from Github
.globalrc/install # execute the script that will link GLOBALRC to your bashrc
. .globalrc/bashrc # source the new configuration to immediately benefit from it
```

It is recommended to remove the `.git` folder from GLOBALRC dir
as it will be copied every time you push or pull your configuration.
This can be done like this:
```sh
rm -rf ~/.globalrc/.git
```

If you want to keep the `.git` folder but you want to place somewhere else
in order to prevent copy of the `.git` folder, you can execute the following commands:
```sh
#! /bin/sh
cd # go to your home
git clone --work-tree=.globalrc https://github.com/csdt/globalrc.git .globalrc.git # clone from Github
echo "gitdir: $(pwd)/.globalrc.git" > .globalrc/.git # tell git how to find '.globalrc.git'
.globalrc/install # execute the script that will link GLOBALRC to your bashrc
. .globalrc/bashrc # source the new configuration to immediately benefit from it
```

### To another machine
If you have GLOBALRC installed on your local machine, and you want to install it on another machine,
the easiest way is to use `pushrc`.

### From another machine
If you have GLOBALRC installed on a remote machine, and you want to install it on your local machine,
you must manually copy the `.globalrc` directory from the remote,
and manually execute the script to link GLOBALRC to your bashrc.

This can be done like that:
```sh
#! /bin/sh
cd # go to your home
scp -r user@hostname:.globalrc/. .globalrc # copy your remote configuration to your local machine
.globalrc/install # execute the script that will link GLOBALRC to your bashrc
. .globalrc/bashrc # source the new configuration to immediately benefit from it
```

## Dependencies
GLOBALRC is conceived with high compatibility in mind and uses the least possible
dependencies and the most common ones.
GLOBALRC is written in `bash` for scripts, and use `ssh` and `scp` to synchronise files.
It uses `ssh-copy-id`, `grep`, `sed`, `cp`, `rm`, `mkdir`, `cat`, `id`, `date`, `ps`, `kill` for internal uses.
It also provides better completion if `bash-completion` is installed on the machine.

Scripts are as most as possible POSIX compliant
and should work with any other POSIX compliant shells like `zsh`, `ksh`, `dash`...
However, shell completion is written exclusively for `bash` and may not work with other shells.

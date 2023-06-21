# General notes

* `nix-channel` and `~/.nix-defexpr` are gone. We'll use `$NIX_PATH` (or user environment specific overrides configured via `nix set-path`) to look up packages. Since `$NIX_PATH` supports URLs nowadays, this removes the need for channels: you can just set `$NIX_PATH` to e.g. `https://nixos.org/channels/nixos-15.09/nixexprs.tar.xz` and stay up to date automatically.

* By default, packages are selected by attribute name, rather than the `name` attribute. Thus `nix install hello` is basically equivalent to `nix-env -iA hello`. The attribute name is recorded in the user environment manifest and used in upgrades. Thus (at least by default) `hello` won't be upgraded to `helloVariant`.

  @vcunat suggested making this an arbitrary Nix expression rather than an attrpath, e.g. `firefox.override { enableFoo = true; }`. However, such an expression would not have a key in the user environment, unlike an attrpath. Better to require an explicit flag for this.

  TBD: How to deal with search path clashes. The idea is that `nix install firefox` will check the search path from left to right, looking for a `firefox` attribute. However, the user may want to have multiple versions of Nixpkgs in the search path, so we'll need some way to specify more precisely.

* By default, we won't show build log output anymore. Instead there will be some progress indicator (e.g. `9/16 packages built, 1234/5678 KiB downloaded`). If a build fails, Nix will print the last N lines of the build log, with a pointer to `nix log` to get the rest.

* Terminology: should ditch either `user environments` or `profiles`.

* All commands that provide output should have a `--json` flag.

* Commands versus flags: A flag should not make a command do something completely different. So no more `nix-instantiate --eval` (since the `--eval` causes `nix-instantiate` to not instantiate anything). However, the opposite, `nix eval --instantiate` might be okay, since it causes instantiation in addition to evaluation.

* TBD: Need some support for discovering / configuring "plugins" (i.e. the stuff currently enabled via `wrapFirefox`, `texlive.combine` etc.). One way would be to allow packages to declare user environment builder hooks to delay stuff like wrapper script generation until the user environment is (re)built. For example, the `firefox` package could declare a hook that iterates over the installed packages, looking for Firefox plugins, and then writes an appropriate wrapper script to `$out/bin/firefox`. As a bonus, this gets rid of the `firefox` / `firefoxWrapper` distinction.

# Main commands

## nix search

Searches for available packages. Replaces `nix-env -qa`.

* To show all available packages:

        $ nix search
        hello                  1.12
        firefox                43.3
        firefox-esr            38.0.3
        perlPackages.DBDSQLite 1.2.3
        ...
        
* To search by package name:

        $ nix search --name 'hel.*'
        hello           1.12
        ...
        
* To search by attribute name:

        $ nix search firefox perlPackages
        firefox                43.3
        perlPackages.DBDSQLite 1.2.3
        perlPackages.XMLSimple 4.5.6
        ...

* Other filters: `--description`, ...

TBD: `nix search` could have a cache.

## nix install

Adds a package to the user environment. (Maybe this should be called `nix add`?)

* Install the Hello package from Nixpkgs:

        $ nix install hello

  This will install the `hello` attribute from the package search path. Assuming that `$NIX_PATH` is `nixpkgs=https://...`, this is equivalent to `nix-env -iA nixpkgs.hello).
  
* Install the Hello package, marking it as "declarative":

        $ nix install -d hello
        
  This gives it semantics similar to `environment.systemPackages` in NixOS: any subsequent operation on the user environment will rebuild `hello` (if necessary) from the then-current Nixpkgs. Without `-d`, the user installs some fixed store paths that are left unchanged by subsequent operations, unless they specifically target that package. For example:
  
        $ nix install -d hello
        ... time passes ...
        $ nix install firefox # <- this may rebuild hello
        ... time passes ...
        $ nix uninstall firefox # <- this may also rebuild hello
        
  while without `-d`, none of the operations on `firefox` will change `hello`.
  
  This is implemented by having the `manifest.nix` for the user environment track non-declarative packages by store path, e.g.
  
        { hello = {
            expr = builtins.storePath /nix/store/abcd1234-hello-1.2.3;
          };
        }
        
  while declarative entries look something like
  
        { hello = {
            expr = (import <nixpkgs> {}).hello;
          };
        }

* Install the Hello package from a Nixpkgs git clone:

        $ nix install -f /path/to/nixpkgs hello

* Install a store path:

        $ nix install /nix/store/abcd1234-hello-1.11
        
  TBD: Since user environments are keyed by attribute name, and we don't have an attribute name here, we have to fake one. We could just use the name part of the store path (i.e. `hello`), or assign a random name. There could be a `--key` flag to override the attribute name.
        
* Copy a package from the default user environment on a remote machine and install it:

        $ nix install mandark:hello

  or from a specific user environment:

        $ nix install mandark:/nix/var/nix/profiles/test:hello

* Copy a store path from a remote machine via SSH and install it:

        $ nix install mandark:/nix/store/abcd1234-hello-1.11

## nix rebuild

Rebuilds the user environment, given the current package search path and the manifest, thus causing declarative packages (those installed with `nix install -d`) to be rebuilt if necessary.

This command is really equivalent to doing an empty `nix install` or `nix uninstall` - it doesn't change the manifest, it just rebuilds it, which in the case of declarative packages can cause a rebuild of those packages.

## nix upgrade

Replaces `nix-env -u`. For each non-declarative user environment element, checks if a more recent package with the same attribute name is available.
        
## nix list

Shows the packages installed in the user environment.

    $ nix list
    hello   1.10
    firefox 43.0

## nix status

Shows installed packages and compares them to available packages. Replaces `nix-env -qc`.

## nix uninstall

Removes a package from the user environment.

    $ nix uninstall hello

## nix rollback

Exactly the same as `nix-env --rollback`.

## nix use

Replaces `nix-shell -p`. It's a different verb from `nix shell` to denote that `nix use` gives you a shell containing a package, while `nix shell` gives you a shell containing the environment for building a package.

* Start a shell containing the `hello` package from the package search path:
```
$ nix use hello
[subshell]$ hello
```

This should also have a way to run a command, but unlike `nix-shell --command <foo>`, the arguments should be positional to remove the need for quoting. E.g.
```
$ nix use hello -c hello --greeting bla
```

## nix sandbox

Like `nix-use`, but runs the shell / command in a namespace where (for instance) it only has access to specific parts of the user's home directory.

## nix set-path

Overrides `$NIX_PATH` for a specific user environment. E.g.

    $ nix set-path nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/8a3eea054838b55aca962c3fbde9c83c102b8bf2.tar.gz
        
will cause Nix to henceforth use the specified version of Nixpkgs for this particular user environment.

Nbp suggested calling this `nix remote` (analogous to `git remote`), however the local/remote terminology doesn't really apply here. A possibility might be `nix source`, e.g.

* `nix source add nixpkgs https://...`
* `nix source add nixpkgs-14.12 https://...`
* `nix source remove nixpkgs-14.12`
* `nix source pin nixpkgs` # put an infinite TTL on downloaded nixpkgs tarball, for nix-channel like behaviour

## nix query-options

Shows per-package options. How exactly packages will declare these options is TBD. Example:

    $ nix query-options emacs
    x11  | true  | Whether to enable X11 GUI support
    cups | false | Whether to enable CUPS printing support
        
Then at install time you can specify these options:

    $ nix install emacs --pkg-option x11 true
        
or maybe

    $ nix install emacs --disable x11 --enable cups

Maybe also a command to modify options:

    $ nix modify emacs --enable x11
        
(This is equivalent to `nix install`, except that it uses previously recorded values for options that are not specified.)

Possibly we could have a `--global` flag for querying global options (like "enable Pulseaudio for all packages that support it").

## nix history

Show the history (log) of changes to a user environment. Improved version of `nix-env --list-generations`. Should show the changes between user environment generations (e.g. `firefox upgraded from 43.0 to 44.0`).

## Transactions

Multiple operations that modify a user environment can be combined in an atomic transaction. For example,

    $ nix uninstall chromium \; install firefox

# Developer commands

## nix build

Replaces `nix-build`, but with Nix expression lookup semantics consistent with the other commands. Thus:

    $ nix build hello
        
builds the `hello` package from package search path, while

    $ nix build -f release.nix tarball
        
builds the `tarball` attribute from the file `release.nix`.

Also,

    $ nix-build /nix/store/abcd1234-hello-1.11
        
is equivalent to `nix-store -r` (i.e. it will fetch the specified path from the binary cache).

## nix shell

* Start a development shell based on `./default.nix` or `./shell.nix`:

        $ nix shell
        
  (Hm, do we want a special case like this?)

* Start a development shell based on the `firefox` attribute in the package search path:

        $ nix shell firefox

* Start a development shell based on the `build.x86_64-linux` attribute in `release.nix`:

        $ nix shell -f release.nix build.x86_64-linux

  (I.e. `nix-shell release.nix -A build.x86_64-linux`.)

* Run a command inside the shell:

        $ nix shell -c make -C target -j10

  Unlike `nix-shell --command`, this uses positional arguments, removing the need to escape the command. Note: this complicates option processing a bit since the position of `-c` is significant (it should come after all package names).

## nix edit

Opens the Nix expression of the specified package in an editor.

    $ nix edit firefox
  
## nix repl

May want to move this into Nix.

## nix eval / parse

These replace `nix-instantiate --eval` and `nix-instantiate --parse`. E.g.

    $ nix eval -E '1 + 2'
    3
        
## nix make-store-derivation

Replaces `nix-instantiate` with a more descriptive if somewhat verbose name.

## nix log

* Show the build log of the given store path:

        $ nix log $(type -p hello)
        
* Show the build log of the given package from the package search path:

        $ nix log hello

## nix fetch-url

Replaces `nix-prefetch-url`.

* Fetch the URL denoted by `hello.src` and print its hash:

        $ nix fetch-url hello.src
        
* Fetch the specified URL and print its hash:

        $ nix fetch-url ftp://ftp.gnu.org/pub/hello/hello-1.10.tar.gz
  
# System administration commands

## nix gc

Deletes old user environment generations and then deletes unreachable store paths. Equivalent to `nix-collect-garbage -d`.

Policy on how long to keep generations can be specified in `nix.conf` (i.e. flags like `--delete-older-than` can now be made sticky).

## nix copy

Copies paths between Nix stores. In Nix 2.0, binary caches and remote
systems are a kind of store.

* Copy the closure of Firefox to a local binary cache:

        $ nix copy --to file:///tmp/my-cache -r $(type -p firefox)

* Copy the closure of Firefox to a binary cache in S3:

        $ nix copy --to s3://nixos-cache -r $(type -p firefox)

* Copy the closure of a path between to binary caches:

        $ nix copy --from https://cache.nixos.org/ --to file:///tmp/my-cache \
            -r /nix/store/lhs110bci7yz6a0p6bbha8kvja3sjyr6-util-linux-2.27.1

* Copy to a remote machine via SSH:

        $ nix copy --to ssh://example.org -r $(type -p firefox)

* Copy from a remote machine via SSH:

        $ nix copy --from ssh://example.org -r /nix/store/lhs110bci7yz6a0p6bbha8kvja3sjyr6-util-linux-2.27.1

# Misc. store-level commands

## nix path-info

Shows info about a store path (size, hash, registration time, signatures, ...).

* E.g. `-s` shows the size of a path:

        $ nix path-info -s /run/current-system
        /nix/store/vrgjb5kh9gs2n3prpsap45syffjy5g5v-nixos-system-foo-16.03.git.8d4ef4dM  47528

* `-S` shows the closure size:

        $ nix path-info -S /run/current-system
        /nix/store/vrgjb5kh9gs2n3prpsap45syffjy5g5v-nixos-system-foo-16.03.git.8d4ef4dM  3224565536

* With `-r`, shows info about the closure of the path:

        $ nix path-info -r -s /run/current-system
        /nix/store/000csds2hcgwy2y8khm3cs4jjqpc92h5-libpaper-1.1.24   47856
        /nix/store/00sc3r8iln5yd3cxaixv63a6a04i31b2-nss-cacert-3.23  251384
        ...

  Or to show paths with the biggest closure in a closure:

        $ nix path-info -r -sS /run/current-system | sort -rnk3 | head
        /nix/store/vrgjb5kh9gs2n3prpsap45syffjy5g5v-nixos-system-foo-16.03.git.8d4ef4dM  47528 3224565536
        /nix/store/l88j4ksdz1d09lrz5zf0iwjg6jgb17ks-etc                                  32808 3089347976
        /nix/store/5zqifi40vh52wp2z1rvyx5nl8apk492j-system-units                         80608 2835439360
        /nix/store/rd58kxz7g6q8kv5s7w13w097clz0yv8s-unit-dbus.service                     1264 2780572336
        ...

## nix substitutes

Shows available substitutes of a given store path.

## nix add-to-store

Replaces `nix-store --add`.

## nix verify

Replaces and extends `nix-store --verify-paths` and `nix-store
--verify`. By default, checks whether paths have at least one valid
signature *and* are not corrupted on disk.

* Verify all paths in the NixOS system closure:

        $ nix verify -r /run/current-system
        ...
        path ‘/nix/store/xfz2ywkml4pf2yqg5wjvfijx1ds4x56l-firmware-linux-nonfree-2016-01-26’ is untrusted
        path ‘/nix/store/v6afsf2pz3xzszhygmyrdbdyv9wsvhaq-oxygen-icons-4.14.3’ is untrusted
        795 paths checked, 384 untrusted, 0 corrupted, 0 failed

* The same, but obtain missing signatures from the specified
  substituter:

        $ nix verify -r /run/current-system -s https://cache.nixos.org
        ...
        path ‘/nix/store/w5yam5fymbxmar39lvrqwrr0xdgqjs20-firewall-reload’ is untrusted
        path ‘/nix/store/z953anwmv7ivdcaw3nff3n90jqf5smm3-vista-fonts-1’ is untrusted
        795 paths checked, 14 untrusted, 0 corrupted, 0 failed

* Verify whether any path in the store has been corrupted (without
  checking sigs):

        $ nix verify --all --no-trust

* Verify a binary cache:

        $ nix verify --all --store file:///tmp/my-cache

## nix print-roots / print-dead / print-live

These replace `nix-store --gc` subcommands.

# Misc. utility commands

## nix hash-file

Replaces `nix-hash --flat`.

## nix hash-path

Replaces `nix-hash` (without `--flat`).

## nix to-base16 / to-base32

Replaces `nix-hash --to-base32 / --to-base32`.

## nix nar

Replaces `nix-store --dump`.

## nix unnar

Replaces `nix-store --restore`.

## nix list-nar

New command to list the contents of a NAR file.
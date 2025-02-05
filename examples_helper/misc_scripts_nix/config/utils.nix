# Usefull functions used everywhere :)
#
# From:
# - https://github.com/ners/NixOS/blob/master/profiles/lib/modules.nix
# - https://github.com/ners/NixOS/blob/master/profiles/lib/attrsets.nix
# - https://github.com/ners/NixOS/blob/master/profiles/lib/lists.nix
# - https://github.com/ners/NixOS/blob/master/profiles/lib/strings.nix
# - https://github.com/ners/NixOS/blob/master/profiles/lib/trivial.nix
{lib, ...}:
with builtins;
with lib; rec {
  ###########
  # MODULES #
  ###########

  # Recurse into a directory tree to find modules and build a nested attrset, with names corresponding to directory
  # structure and values the full path to the module which can be imported.
  # A module is either a nix file not named default.nix, or a directory containing a default.nix.
  # Recursion stops when a module is found, e.g. a file lib.nix in a directory containing default.nix will not be found.
  findModules = dir:
    pipe dir [
      readDir
      attrsToList
      (foldr
        ({
          name,
          value,
        }: acc: let
          fullPath = dir + "/${name}";
          isNixModule =
            value
            == "regular"
            && hasSuffix ".nix" name
            && name
            != "default.nix";
          isDir = value == "directory";
          isDirModule = isDir && readDir fullPath ? "default.nix";
          module =
            nameValuePair (removeSuffix ".nix" name)
            (
              if isNixModule || isDirModule
              then fullPath
              else if isDir
              then findModules fullPath
              else {}
            );
        in
          if module.value == {}
          then acc
          else append module acc) [])
      listToAttrs
    ];

  ###########
  # ATTRSET #
  ###########

  # Utility function that converts an attrset to a list of {name, value} pairs.
  # Inverse of builtins.listToAttrs: listToAttrs (atrsToList attrs) == attrs
  attrsToList = mapAttrsToList nameValuePair;

  # Convert a single {name, value} pair to a corresponding attrset
  nameValuePairToAttrs = pipef [singleton listToAttrs];

  # Modify the name field of an attrset by mapping it through a function.
  mapName = f: attrs:
    assert assertMsg (isFunction f) f;
    assert assertMsg (isAttrs attrs) attrs;
      attrs
      // {
        name = f attrs.name;
      };

  # Flatten an attrset by bringing all the leaves to the top level.
  # As there is no singular name flattening strategy, the result is a list of
  # NameValuePairs, where the name is a list of parts.
  #
  # Example:
  # flattenAttrs { a = { b = 3; c = true; }; d = "paramecium"; }
  # => [ { name = ["a" "b"]; value = 3; } { name = ["a" "c"]; value = true; } { name = ["d"]; value = "paramecium"; } ]
  flattenAttrs = flattenAttrsCond (const true);

  # Like `flattenAttrs', but takes an additional predicate function that tells
  # it whether to recurse into an attribute set.
  flattenAttrsCond = cond:
    pipef [
      (mapAttrsToList (name: nameValuePair (singleton name)))
      (foldr
        (p @ {
          name,
          value,
        }: acc:
          if isAttrs value && cond value
          then acc ++ pipe value [flattenAttrs (map (mapName (n: name ++ n)))]
          else append p acc) [])
    ];

  # Applies the merge function to the output of flattenAttrs, producing an attrset.
  # The merge function converts each {name, value} pair to one in which the name is
  # merged into a single string, and may change the value as well.
  flattenAttrsWith = merge:
    pipef [
      flattenAttrs
      (map (pipef [merge nameValuePairToAttrs]))
      (foldr recursiveUpdate {})
    ];

  #########
  # LISTS #
  #########

  # Prepend a value to a list
  prepend = x: xs: [x] ++ xs;

  # Append a value to a list
  append = x: xs: xs ++ [x];

  # Return true if function `pred` returns false for all elements of `xs`.
  none = pred: xs: !(any pred xs);

  ###########
  # STRINGS #
  ###########

  # Splits the string by newlines into a list of strings
  lines = splitString "\n";

  # Merges a list of string by newline into a single multiline string
  unlines = concatStringsSep "\n";

  # Read the list of files and concatenate their contents by the given separator
  concatFilesSep = sep: pipef [(map readFile) (concatStringsSep sep)];

  #########
  # UTILS #
  #########

  # Pipes a value through a list of functions.
  # Produces a lambda that accepts a starting value when called with just a list of functions.
  pipef = flip pipe;
}

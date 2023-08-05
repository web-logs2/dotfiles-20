#!/usr/bin/env fish

function has_command
    command -v $argv[1] >/dev/null 2>&1
end

if has_command fish
    yes | fish_config theme save 'ayu Mirage'
    yes | fish_config prompt save informative
end

exit 0
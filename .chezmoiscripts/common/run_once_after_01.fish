#!/usr/bin/env fish

if has_command fish
    yes | fish_config theme save 'ayu Mirage'
    yes | fish_config prompt save informative
end

exit 0

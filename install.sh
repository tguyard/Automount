#!/bin/sh

AUTOMOUNT=~/.config/awesome/automount
UDISKS_GLUE_CONF=~/.udisks-glue.conf

[ -e "$AUTOMOUNT" ] || mkdir "$AUTOMOUNT"
[ $? ] || exit -1

cp ./dd-update ./udisks-glued "$AUTOMOUNT"

if [ -e "$UDISKS_GLUE_CONF" ] ; then
    echo .udisks-glue.conf already exists. you should update it yourself.
else
    cp ./udisks-glue.conf "$UDISKS_GLUE_CONF"
fi

cat << EOF 
 ============================================================================
|                                                                            |
|    Add this in you rc.lua file.                                            |
|                                                                            |
 ============================================================================

-- your rc.lua must contain this function :
function createDDWidget (name, mounted)
    dd = widget({ type = "textbox" })
    if mounted == "" then
        dd.text = "<span color=\"gray\"> " .. name .. " </span>"
        dd:buttons(awful.util.table.join(
            awful.button({ }, 1, function () os.execute("udisks --mount /dev/" .. name) end),
            awful.button({ }, 3, function () os.execute("udisks --unmount /dev/" .. name) end)
        ))
    else
        dd.text = "<span color=\"white\"> " .. mounted .. " </span>"
        dd:buttons(awful.util.table.join(
            awful.button({ }, 1, function () os.execute("udisks --mount /dev/" .. name) end),
            awful.button({ }, 3, function () os.execute("udisks --unmount /dev/" .. name) end),
            awful.button({ }, 2, function () os.execute("echo -n /media/" .. mounted .. " | xclip -i") end)
        ))
    end
    return dd
end

-- this function is used to add the widget. You will want to customize it
function addDDWidget (widgets)
    right_widgets=2
    dd_widgets=5

    mywibox[default_screen].widgets[right_widgets][dd_widgets] = widgets
    mywibox[default_screen].widgets[right_widgets][dd_widgets].layout = awful.widget.layout.horizontal.rightleft
end

-- You also have to add this lines (launch the scripts on startup)
os.execute(awful.util.getdir("config") .. "/automount/dd-update &")
os.execute(awful.util.getdir("config") .. "/automount/udisks-glued start &")
EOF

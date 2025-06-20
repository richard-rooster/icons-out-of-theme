#! /usr/bin/fish
 
#THEME FOLDERS TO CHECK
#~/.local/share/icons
#/usr/share/icons
 
#TO DO
#HANDLE THEME FOLDERS WITH FREEDESKTOP DEFINITIONS
#$HOME/.icons
#$XDG_DATA_DIRS/icons
#/usr/share/pixmaps
 
#HANDLE PLASMA, HANDLE OTHER GSETTINGS DE
switch $XDG_CURRENT_DESKTOP
case 'GNOME' 'XFCE' 'Hyprland' 'MATE' 'LXQt' 'Enlightenment' 'Deepin' 'Budgie:GNOME' 'LXDE' 'Pantheon' 'OPENBOX'
	set ICON_THEME (gsettings get org.gnome.desktop.interface icon-theme)
case 'Cinnamon', 'X-Cinnamon'
	set ICON_THEME (gsettings get org.cinnamon.desktop.interface icon-theme)
case 'KDE'
	#plasma-apply-nnn --list
	echo 'not yet implemented for plasma'
	return 0
case '*'
	echo $XDG_CURRENT_DESKTOP
	echo $ICON_THEME
	echo 'handling for current desktop not yet implemented'
end
 
set EXEC_LABEL 'Exec='
set ICON_LABEL 'Icon='
set DESKTOP_EXTENSION '.desktop'
set OPT_DIR '/opt'
set ICON_THEME (string replace --all "'" "" $ICON_THEME)
set HOME_THEME_FOLDER (string join '' $HOME '/.local/share/icons/' $ICON_THEME '/')
set GLOBAL_THEME_FOLDER (string join '' '/usr/share/icons/' $ICON_THEME)

string match -q '*'$OPT_DIR'*' $PATH
switch $status
case 0
	set INSTALLED_PACKAGES (find $PATH)
case '*'
	set INSTALLED_PACKAGES (find $PATH $OPT_DIR)
end #switch status

set ICON_FILES (find $HOME_THEME_FOLDER $GLOBAL_THEME_FOLDER)

for USER_DIR in $XDG_DATA_DIRS
	set APP_DIR (string join '' $USER_DIR '/applications')
	if test -d $APP_DIR
		set DESKTOP_FILES (find (string join '' $USER_DIR '/applications'))
		for DESKTOP in $DESKTOP_FILES
			string match -q '*'$DESKTOP_EXTENSION'*' $DESKTOP
			switch $status
			case 0
				set EXPECTED_EXECS (cat $DESKTOP | grep $EXEC_LABEL)
				for EXEC in $EXPECTED_EXECS
					for EXEC_WORD in (string split ' ' (string replace $EXEC_LABEL '' $EXEC))
						string match -q '*'$EXEC_WORD'*' $INSTALLED_PACKAGES
						switch $status
						case 0
							set EXPECTED_ICONS (cat $DESKTOP | grep $ICON_LABEL)
							set ICON_FOUND 1
							set POSSIBLE_NAMES ''
							for icon in $EXPECTED_ICONS
								string match -q '*'(string replace $ICON_LABEL '' $icon)'*' $ICON_FILES
								switch $status
								case 0
									set ICON_FOUND 0
								case '*'
									set POSSIBLE_NAMES (string join ' ' $POSSIBLE_NAMES (string replace $ICON_LABEL '' $icon))
								end #switch $status
								switch $ICON_FOUND
								case 1
									echo $DESKTOP 'has no matching icon named any of { ' $POSSIBLE_NAMES ' } in' $ICON_THEME
								end #switch $ICON_FOUND
							end #for icon in $EXPECTED_ICONS
							break
						end #switch $status
					end #for EXEC_WORD in ....
				end #for EXEC in $EXPECTED_EXECS
			end #switch $status
		end #for DESKTOP in $DESKTOP_FILES
	end # if test -d $APP_DIR
end #for USER_DIR in $XDG_USER_DIRS

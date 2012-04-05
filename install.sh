#!/bin/sh

UUID="weather@mockturtl"
OLD_UUID="cinnamon-weather@mockturtl"
SCHEMA_DIR="/usr/share/glib-2.0/schemas/"
OLD_SCHEMA="${OLD_UUID}.gschema.xml"
SCHEMA="org.cinnamon.applets.${UUID}.gschema.xml"
INSTALL_DIR="${HOME}/.local/share/cinnamon/applets/${UUID}"
OLD_INSTALL_DIR="${HOME}/.local/share/cinnamon/applets/${OLD_UUID}"
LOCALES="ca cs de es fi fr he it lv nb nl pl pt ro ru sk sv uk zh_CN"
LOCALE_DIR="${HOME}/.local/share/locale"


do_install() {
	cat << EOF

	Installing applet in ${INSTALL_DIR}...
EOF
	
	sudo cp -f ${SCHEMA} ${SCHEMA_DIR} &&
		glib-compile-schemas --dry-run ${SCHEMA_DIR} &&
		sudo glib-compile-schemas ${SCHEMA_DIR}

	mkdir -p ${INSTALL_DIR}

	sudo ln -sf ${INSTALL_DIR}/cinnamon-weather-settings /usr/local/bin
	cp -f metadata.json applet.js cinnamon-weather-settings icon.png stylesheet.css ${INSTALL_DIR}

	cat << EOF
	Installing applet locales in ${LOCALE_DIR}...
EOF
	for LOCALE in ${LOCALES}; do
		mkdir -p ${LOCALE_DIR}/${LOCALE}/LC_MESSAGES
		msgfmt -c po/${LOCALE}.po -o ${LOCALE_DIR}/${LOCALE}/LC_MESSAGES/${UUID}.mo
	done

	chown -R ${USER} ${INSTALL_DIR} ${LOCALE_DIR} 2>/dev/null
}

do_uninstall() {
	cat << EOF

	Removing applet from ${INSTALL_DIR} ...
EOF
	if [ -f "${SCHEMA_DIR}/${SCHEMA}" ]; then
		sudo rm -f ${SCHEMA_DIR}/${SCHEMA}
		dconf reset -f /org/cinnamon/applets/weather@mockturtl/
	fi

	sudo rm -f ${SCHEMA_DIR}/${SCHEMA} &&
		glib-compile-schemas --dry-run ${SCHEMA_DIR} &&
		sudo glib-compile-schemas ${SCHEMA_DIR}

	rm -rf ${INSTALL_DIR}
	sudo rm -f /usr/local/bin/cinnamon-weather-settings

	cat << EOF
	Removing applet locales from ${LOCALE_DIR} ...
EOF
	for LOCALE in ${LOCALES}; do
		rm -f ${LOCALE_DIR}/${LOCALE}/LC_MESSAGES/${UUID}.mo
	done
}

do_cleanup() {
	cat << EOF

	Removing old installation of applet from ${OLD_INSTALL_DIR}...
EOF
	if [ -f "${SCHEMA_DIR}/${OLD_SCHEMA}" ]; then
		sudo rm -f ${SCHEMA_DIR}/${OLD_SCHEMA}
		dconf reset -f /org/cinnamon/weather/
	fi
	
	glib-compile-schemas --dry-run ${SCHEMA_DIR} &&
		sudo glib-compile-schemas ${SCHEMA_DIR}
	
	rm -rf ${OLD_INSTALL_DIR}
		
	cat << EOF
	Removing old applet locales from ${LOCALE_DIR} ...
EOF
	for LOCALE in ${LOCALES}; do
		rm -f ${LOCALE_DIR}/${LOCALE}/LC_MESSAGES/${OLD_UUID}.mo
	done
}

case `basename $0` in
	"install.sh")
		do_install
		;;
	"uninstall.sh")
		do_uninstall
		;;
	"cleanup.sh")
		do_cleanup
		;;
esac

cat << EOF

	*** You need to restart Cinnamon ( Alt-F2 => "r" <enter> ) ***

EOF

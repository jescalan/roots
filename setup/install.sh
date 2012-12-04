# -----------------------------------------------
# print utilities, shamelessly jacked from yeoman
# -----------------------------------------------

happy_print(){
  printf '\e[32m%s\e[0m \e[1m%s\e[0m %s\n' "✓" "$1" "$2"
}

sad_print(){
  printf '\e[31m%s\e[0m \e[1m%s\e[0m %s\n' "✘" "$1" "$2"
}

# -------------------------------------------
# this is the whole script. it's quite simple
# -------------------------------------------

if [[ -x $(command -v node) && $(node -e 'console.log(process.versions.node);') > 0.8.0 ]]; then
  echo ""
  happy_print 'node is installed and up to date!'
  printf "\e[33m%s\e[0m" "  installing roots..."
  echo "\n"
  npm install roots -g
  echo ""
  echo "--------------------------------------------------------------"
  printf '\e[32m%s\e[0m\n' 'roots installed successfully!'
  echo "type \`roots help\` or visit http://roots.cx to get started."
  echo "--------------------------------------------------------------"
  echo ""
else
  echo ""
  sad_print "looks like you need to install or update node.js."
  echo ""
  echo "I'll open up the node.js website for you."
  echo "Click the big green button to download the installer, then"
  echo "install it and run me again when you're finished!"
  echo ""
  sleep 3
  open "http://nodejs.org/"
fi
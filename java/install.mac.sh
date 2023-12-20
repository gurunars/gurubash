APP_NAME=java $INSTALL

LOCATION=/Library/Java/JavaVirtualMachines/openjdk.jdk

if [ -e $LOCATION ]; then
    echo "OpenJDK is already configured"
else
    sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk \
      $LOCATION
fi

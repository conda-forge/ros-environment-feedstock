mkdir build
cd build

# turn this into a catkin workspace by adding the catkin token if it doesn't
# exist already
if [ ! -f $PREFIX/.catkin ]; then
    touch $PREFIX/.catkin
fi

# necessary for correctly linking SIP files (from python_qt_bindings)
export LINK=$CXX

export ROS_PYTHON_VERSION=`${PYTHON} -c "import sys; print('%i.%i' % (sys.version_info[0:2]))"`
echo "Using Python $ROS_PYTHON_VERSION"

# NOTE: there might be undefined references occurring
# in the Boost.system library, depending on the C++ versions
# used to compile Boost. We can avoid them by forcing the use of
# the header-only version of the library.
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX \
		 -DCMAKE_PREFIX_PATH=$PREFIX \
		 -DCMAKE_INSTALL_LIBDIR=lib \
		 -DCMAKE_BUILD_TYPE=Release \
		 -DCATKIN_BUILD_BINARY_PACKAGE="1" \
		 -DSETUPTOOLS_DEB_LAYOUT=OFF

make VERBOSE=1 -j${CPU_COUNT}
make install

# copy activation scripts to conda environment
mkdir -p "${PREFIX}/etc/conda/activate.d"
for SCRIPT in "1.ros_distro.sh" "1.ros_etc_dir.sh" "1.ros_package_path.sh" "1.ros_python_version.sh" "1.ros_version.sh"
do
  cp "${PREFIX}/etc/catkin/profile.d/${SCRIPT}" "${PREFIX}/etc/conda/activate.d/${SCRIPT}"
done

mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/ros_deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/ros_deactivate.sh"


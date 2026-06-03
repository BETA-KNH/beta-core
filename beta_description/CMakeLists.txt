cmake_minimum_required(VERSION 3.8)
project(beta_description)

find_package(ament_cmake REQUIRED)

# ---------------------------------------------------------------------------
# Meshes — sourced from unitree_ros, fetched via vcs:
#   vcs import src < src/beta-core/src.repos   (run from workspace root)
# The cloned repo lands at <ws>/src/unitree_ros/ which is ../../ relative
# to this package inside beta-core.
# ---------------------------------------------------------------------------
set(G1_MESHES_SRC
  "${CMAKE_CURRENT_SOURCE_DIR}/../../unitree_ros/robots/g1_description/meshes"
  CACHE PATH "Path to Unitree G1 STL meshes (from unitree_ros clone)")

if(EXISTS "${G1_MESHES_SRC}")
  install(
    DIRECTORY "${G1_MESHES_SRC}/"
    DESTINATION share/${PROJECT_NAME}/meshes
    FILES_MATCHING
      PATTERN "*.STL"
      PATTERN "*.stl"
  )
else()
  message(WARNING
    "G1 meshes not found at ${G1_MESHES_SRC}.\n"
    "Fetch them with: vcs import src < src/beta-core/src.repos  (from workspace root)")
endif()

install(
  DIRECTORY urdf launch config
  DESTINATION share/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()

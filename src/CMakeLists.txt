set(dtt_SRS
	main.cpp
	dbmanager.cpp
	task.cpp
	taskmanager.cpp
	pendingtasks.cpp
	wiptasks.cpp
	completedtasks.cpp
)

set(dtt_RCC
	resources.qrc
)

add_executable(dtt ${dtt_SRS} ${dtt_RCC})
target_link_libraries(dtt Qt5::Core Qt5::Quick Qt5::Widgets Qt5::QuickControls2 Qt5::Sql Qt5::Charts)

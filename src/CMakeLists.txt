set(dtt_SRS
	main.cpp
)

set(dtt_RCC
	resources.qrc
)

add_executable(dtt ${dtt_SRS} ${dtt_RCC})
target_link_libraries(dtt Qt5::Core Qt5::Quick Qt5::Widgets Qt5::QuickControls2)

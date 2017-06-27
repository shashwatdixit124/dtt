set(dtt_SRS
	main.cpp
)

add_executable(dtt ${dtt_SRS})
target_link_libraries(dtt Qt5::Core Qt5::Quick Qt5::Widgets Qt5::QuickControls2)

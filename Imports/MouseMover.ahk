#SingleInstance

SetTimer DetectInactivity, 60000
DetectInactivity()
{
	; 5 Minutes
	maxIdleTime := 360000
	static idleEventCount := 0
	if A_TimeIdle > maxIdleTime
	{
		idleEventCount += 1
		MouseMove (idleEventCount&1) ? 5 : -5, 0, , "R"
	}
}
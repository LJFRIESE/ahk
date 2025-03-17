#SingleInstance

; 5 Minutes
SetTimer DetectInactivity, 30000
DetectInactivity()
{
	maxIdleTime := 6000
	static idleEventCount := 0
	if A_TimeIdle > maxIdleTime
	{
		idleEventCount += 1
		MouseMove (idleEventCount&1) ? 5 : -5, 0, , "R"
	}
}
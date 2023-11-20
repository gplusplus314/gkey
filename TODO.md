- Make a behavior feature for hold-tap along the lines of
`trigger-idle-positions`
  - Should take an array of key positions. When a key is pressed in any one of
	those positions, `require-prior-idle-ms` should effectively be ignored.
	Another way of stating this is if a key in one of the listed positions is
	pressed, assume that the mod-tap key is starting in an idle state.
	- The use case is for typing delimiters directly before a mod-tap during fast
		typing. A concrete use case is typing a capital letter immediately after
	  typing a space, such as at the beginning of a new sentence. This would allow
	  rolling from the space key to a home-row-mod shift.
		- Prototyped [here](https://github.com/gplusplus314/zmk/tree/trigger-idle).

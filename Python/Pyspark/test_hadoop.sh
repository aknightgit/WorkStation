hadoop jar $STREAM	\
-files ~/sandbox/wcmap.py,~/sandbox/wcreduce.py \
-mapper ~/sandbox/wcmap.py 	\
-reducer ~/sandbox/wcreduce.py 	\
-input input \
-output output

C---------------------------------------------------------------
C MODIFICATION HISTORY
C   14 Jul 2014 - hma - Copied from Xianming's PFC simulation
C                       for my PCB simulation.
C---------------------------------------------------------------   

C == choose one mode to build the code

C = inorganic mercury chemistry is the default mode

C = mercury chemistry with methylmercury 
#undef METHY_MODE

C = with food web, following model of Asif Quesi
#undef FOODW_MODE

C = FOODW_MODE needs METHY_MODE
#ifdef FOODW_MODE
#define METHY_MODE
#endif

C = partition
C no partition
#undef PART_NO
C instantaneous equilibrium
#define PART_EQ
C release
#undef PART_DI

C = a seperate tracer for riverine HgP
#undef HGPRIVER

C Sea spray, for PFCs
#undef ALLOW_SEASPRAY


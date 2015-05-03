### Master Channel
# Keeps track of a list of channels
# generates a "report" of channel values
# convenience functions for adding user comments
# package and save data

type Experiment
	instruments
	channels::array{Channel,1}
end

function report(expt::Experiment)
	
end
function []=RAKE(keys_num)
	
	% if number of keywords was not given, use default = 5
	if (~exist('keys_num', 'var'))
        keys_num = 5;
    end
	
	% read the file into a string
	filename = 'text.txt';
	string_of_file = fileread(filename);
	
	% read the stopwords file into a string and generate the stopwords cell array
	stopwords_file = 'stop_words.txt';
	string_of_stopwords = fileread(stopwords_file);
	stopwords = strsplit(string_of_stopwords);
	%  add a space before and after every stopword to avoid splitting words that
	%   contain that stopword ( like : linear -> l-in-ear)
	stopwords_spaces = stopwords;
	for i=1:length(stopwords)
		stopwords_spaces(i) = strcat({' '},stopwords(i),{' '});
	end
	
	% split the string into words
	delimiters = {'.',',',';','?','\n','\r','\f','\v','\t'};
	candidate_words = strsplit(string_of_file,union(delimiters,stopwords_spaces));
	
	% since there are still some stopwords left because there are cases of 
	%  [space]<stopword>[space]<stopword>[space] where only one of them is removed
	%  we will have to manually look for the last and first word in every candidate_word
	%  and remove it in case it's a stop word
	for i=1:length(candidate_words)
		% seperate the candidate word on single words
		temp_words = strsplit( cell2mat(candidate_words(i)) );
		% check if there is a stop word at the begining of the candidate word
		if(ismember(temp_words(1),stopwords))
			candidate_words(i)={''};
			for j=2:length(temp_words)
				%recreate the candidate word
				if(j==2)
					space = {''};
				else
					space = {' '};
				end
				candidate_words(i) = strcat(candidate_words(i),space,temp_words(j));
			end
		end
		% check if there is a stop word at the ending of the candidate word
		if(ismember(temp_words(end),stopwords))
			candidate_words(i)={''};
			for j=1:length(temp_words)-1
				%recreate the candidate word
				if(j==1)
					space = {''};
				else
					space = {' '};
				end
				candidate_words(i) = strcat(candidate_words(i),space,temp_words(j));
			end
		end
	end
	
	% clear the candidate words from any empty cells	
	candidate_words = deblank(candidate_words);
	candidate_words = candidate_words(~cellfun('isempty',candidate_words));
	
	% keep in the unique words only one instance of each candidate word
	unique_words = unique(candidate_words);
	% 1st row : unique_word index
	unique_words_counter(:,1)=[1 : length(unique_words)];
	% 2nd row : deg(w)/freq(w) (candidate word's)
	unique_words_counter(:,2)=zeros(1, length(unique_words));
	
	% seperate the unique candidate words into single words 
	%  (ex. 'linear constraints' -> 'linear' 'constraints')
	single_words = cell(0);
	single_words_counter = zeros(0,5);
	for i=1:length(unique_words)
		split_word = strsplit( cell2mat(unique_words(i)) );
		for j=1:length(split_word)
			if ( strcmp(split_word(j),{''}) ~= 1 )
				if(~ismember(split_word(j),single_words))
					% keep the actual word in single_words
					single_words(end+1)= split_word(j);
					% 1st row : single_word index
					single_words_counter(end+1,1) = length(single_words);
					% 2nd row : unique_word index
					single_words_counter(end,2) = i;
					% 3rd row : deg(w)
					single_words_counter(end,3) = 0;
					% 4th row : freq(w)
					single_words_counter(end,4) = 0;
					% 5th row : deg(w)/freq(w) (single word's)
					single_words_counter(end,5) = 0;
				else
					% if the single word exists already, find it's index
					[index] = find_in_cellarray(single_words, split_word(j));
					
					% and keep in the 3rd dim (index,2,k (k = the first non zeros element)) 
					%  the additional unique words that contain it 
					k = find(single_words_counter(index,2,:)==0);
					if(length(k) > 0) 
						single_words_counter(index,2,k(1)) = i;
					else
						single_words_counter(index,2,end+1) = i;
					end
					
				end
			end
		end
	end
	
	% calculate how many times each single word appears 
	%  within the candidate words (which is basically our text - stopwords)
	for i=1:length(single_words)
		for j=1:length(candidate_words)

			% for each unique word that contains this single word
			additional_uniq_words = find(single_words_counter(i,2,:)>0);
			for u=1:additional_uniq_words(end)
				% compare the whole unique word if it has more words than 1
				%  to find if there should be an increase to the single word's degree
				uniq_word = unique_words(single_words_counter(i,2,u)); 
				if(strcmp(single_words(i),uniq_word) ~= 1 )
					if ( strcmp(candidate_words(j),uniq_word) == 1 )
						% count how many words are in the candidate word
						words_count = length( strsplit( cell2mat(candidate_words(j)) ) );
						% if it matches, then it matches with words_count more words 
						%  (deg(w)+words_count, freq(w)+words_count)
						single_words_counter(i,3,1) = single_words_counter(i,3,1) + words_count-1;
					end
				end
			end
			
			% analyze the candidate word into single words and check if any on them
			%  is the same to the one we examine
			split_word = strsplit( cell2mat(candidate_words(j)) );
			for k=1:length(split_word)
				if ( strcmp(split_word(k),single_words(i)) == 1 )
					% if it matches, then it matches with it's self ( freq(w)+1 )
					single_words_counter(i,4,1) = single_words_counter(i,4,1) + 1;
					single_words_counter(i,3,1) = single_words_counter(i,3,1) + 1;
				end
			end
			
		end
		% calculate the deg(w)/freq(w) for the single word
		single_words_counter(i,5,1) = single_words_counter(i,3,1) / single_words_counter(i,4,1) ;
		% for each unique word that contains this single word
		additional_uniq_words = find(single_words_counter(i,2,:)>0);
		for u=1:additional_uniq_words(end)
			% add the deg(w)/freq(w) of the single word to the
			% deg(w)/freq(w) of the unique word that contains it
			unique_words_counter( single_words_counter(i,2,u) ,2 ) = unique_words_counter( single_words_counter(i,2,u) ,2 ) + single_words_counter(i,5,1);
		end
		
	end
	
	% sord the unique words counter based on the 2nd row (deg(w)/freq(w) ) and desc order
	% for easier access to the final keywords
	unique_words_counter = sortrows(unique_words_counter,-2);
	
	% output the final keywords as the unique words with the highest scores
	if(length(unique_words) < keys_num )
		keys_num = length(unique_words);
	end
	disp('Rake Keywords Extracted : ');
	for i=1:keys_num
		keywords(i)=unique_words( unique_words_counter(i,1) );
		disp(['  ',cell2mat(keywords(i)) ,' ( deg/freq : ', num2str(unique_words_counter(i,2)) , ' )']);
	end

end


% function to find a cell location in a cell array
%  apparently there was no build in function for it
function [index] = find_in_cellarray(array, cell)
	if( length(array) ~= 0 )
		if ( strcmp(array(end),cell) == 1) 
			index = length(array);
		else
			array(end)=[];
			[index] = find_in_cellarray(array, cell);
		end
	else
		index=0;
	end
end
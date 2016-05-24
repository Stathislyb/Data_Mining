%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 							Exercise 2 									%%
%% 						Lymperidis Efstathios 							%%
%%                          AEM : 186									%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	function : mykNN  
%%  Line : 469					
%%	use  :[TestLabels] = mykNN(TestData, TrainData, Labels, k) 
%%
%%	function : read_file
%%  Line : 335	 				
%% 	use  :[Dataset] = read_file(file_name)
%%
%%	function : train66_test34 
%%  Line : 368			
%% 	use  :[TrainData,TrainLabels,TestData,TestLabels] = train66_test34(Dataset)
%%
%%	function : TenFoldCrossValidation  
%%  Line : 425
%% 	use  :[TenFoldData,TenFoldLabels] = TenFoldCrossValidation(Dataset)
%%
%%	function : make_conf_matrix  
%%  Line : 592	
%% 	use  :[Confusion_Matrix] = make_conf_matrix(Real_TestLabels, Algo_TestLabels)
%%
%%	function : myWeightedKnn  
%%  Line : 626
%% 	use  :[TestLabels] = myWeightedKnn(TestData, TrainData, Labels, k)


function Exercise2()
	% file of our data
	file_name='data.txt';
	
	
	
	% read the input file and create a dataset
	[Dataset] = read_file(file_name);

	
	
	%%%		  		 %%%
	%% Simple k means %%
	%%%				 %%%
	disp('Simple k means');
	
	
	%%%		  		 	 	   %%%
	%% 10 fold cross validation %%
	%%%				 		   %%%
	disp('Running 10 fold cross validation');
	
	% split the dataset for 10 fold cross validation
	[TenFoldData,TenFoldLabels] = TenFoldCrossValidation(Dataset);
	% int. some values for the plots and finding the best k
	time=zeros(15,1);
	max_acc=-1;
	best_k=0;
	for k=1:15
		% int. confusion matrix with zeros
		Confusion_Matrix__temp1= zeros(2);
		for i=1:10
			% init with zeros the datasets, later this extra line
			%  will be removed but we need it to append the data correctly
			TrainData = zeros(1,9);
			TrainLabels=zeros(1,1);
			TestData=zeros(1,9);
			TestLabels=zeros(1,1);
			
			% one fold will be used as test
			%  and the rest of them will be joined and used as train
			for j=1:10
				if i~=j
					TrainData = [TrainData ; TenFoldData(:,:,j)];
					TrainLabels = [TrainLabels ; TenFoldLabels(:,j)];
				else
					TestData = TenFoldData(:,:,j);
					TestLabels = TenFoldLabels(:,j);
				end
			end
			
			% appending the datasets is done trim the lines with zeros
			%  some of those lines may be from folds having 
			%  1 less or extra row in them
			TrainData(~any(TrainData,2), : )=[];
			TrainLabels(~any(TrainLabels,2), : )=[];
			TestData(~any(TestData,2), : )=[];
			TestLabels(~any(TestLabels,2), : )=[];
			
			% run k-means
			tic;
			[Algo_TestLabels] = mykNN(TestData, TrainData, TrainLabels, k) ;
			time(k)=time(k)+toc;
			% make the confusion matrix
			[Confusion_Matrix] = make_conf_matrix(TestLabels, Algo_TestLabels);
			% sum the cunfision matrix results
			Confusion_Matrix__temp1= Confusion_Matrix__temp1+ Confusion_Matrix;
		end
		
		% calculate accuracy and find the k with the best one
		temp_acc = ( Confusion_Matrix__temp1(1,1)+Confusion_Matrix__temp1(2,2) )/sum(sum(Confusion_Matrix__temp1));
		if temp_acc > max_acc
			% keep the possibly best k's results
			Confusion_Matrix_1=Confusion_Matrix__temp1;
			max_acc = temp_acc;
			best_k=k;
			% calculate results
			Sensitivity(1,1)=Confusion_Matrix_1(1,1)/( Confusion_Matrix_1(1,1)+Confusion_Matrix_1(2,1) );
			Specificity(1,1)=Confusion_Matrix_1(2,2)/( Confusion_Matrix_1(1,2)+Confusion_Matrix_1(2,2) );
			Accuracy(1,1)=( Confusion_Matrix_1(1,1)+Confusion_Matrix_1(2,2) )/sum(sum(Confusion_Matrix_1)) ;
		end
		
		% keep accuracy for plot and finding best k
		acc(k)=temp_acc;
	end
	
	% give k the best value found by 10fold cross validation
	k=best_k;


	
	%%%		  		     %%%
	%% Train 66% Test 34% %%
	%%%				     %%%
	disp('Running 66%-34%');
	
	% split the dataset by 66% for train and 34% for test
	[TrainData,TrainLabels,TestData,TestLabels] = train66_test34(Dataset);
	% run k-means
	[Algo_TestLabels] = mykNN(TestData, TrainData, TrainLabels, k) ;
	% make the confusion matrix
	[Confusion_Matrix_2] = make_conf_matrix(TestLabels, Algo_TestLabels);
	% calculate results
	Sensitivity(2,1)=Confusion_Matrix_2(1,1)/( Confusion_Matrix_2(1,1)+Confusion_Matrix_2(2,1) );
	Specificity(2,1)=Confusion_Matrix_2(2,2)/( Confusion_Matrix_2(1,2)+Confusion_Matrix_2(2,2) );
	Accuracy(2,1)=( Confusion_Matrix_2(1,1)+Confusion_Matrix_2(2,2) )/sum(sum(Confusion_Matrix_2)) ;
	
	
	%%%				%%%
	%% Leave one out %%
	%%%				%%%
	disp('Running leave one out')
	
	% int. confusion matrix with zeros
	Confusion_Matrix_3= zeros(2);
	% repeat for each row in dataset
	datanum = size(Dataset,1);
	for i=1:datanum
		
		% keep the dataset to a temporary dataset
		temp_TrainDataset = Dataset(:,[1:9]);
		temp_TrainLabels = Dataset(:,10);
		% and remove the row we will use for test
		temp_TrainDataset(i,:) = [];
		temp_TrainLabels(i,:) = [];
		
		% run k-means
		[Algo_TestLabels] = mykNN(Dataset(i,[1:9]), temp_TrainDataset, temp_TrainLabels, k) ;
		% make the confusion matrix
		[Confusion_Matrix] = make_conf_matrix(Dataset(i,10), Algo_TestLabels);
		
		% sum the cunfision matrix results
		Confusion_Matrix_3 = Confusion_Matrix_3+Confusion_Matrix;
	end
	% calculate results
	Sensitivity(3,1)=Confusion_Matrix_3(1,1)/( Confusion_Matrix_3(1,1)+Confusion_Matrix_3(2,1) );
	Specificity(3,1)=Confusion_Matrix_3(2,2)/( Confusion_Matrix_3(1,2)+Confusion_Matrix_3(2,2) );
	Accuracy(3,1)=( Confusion_Matrix_3(1,1)+Confusion_Matrix_3(2,2) )/sum(sum(Confusion_Matrix_3)) ;
	
	disp(' ');
	%%%		  		   %%%
	%% Weighted k means %%
	%%%				   %%%
	disp('Weighted k means');
	
	%%%		  		 	 	   %%%
	%% 10 fold cross validation %%
	%%%				 		   %%%
	disp('Running 10 fold cross validation');
	
	% split the dataset for 10 fold cross validation
	[TenFoldData,TenFoldLabels] = TenFoldCrossValidation(Dataset);
	% int. confusion matrix with zeros
	Confusion_Matrix_w1= zeros(2);
	for i=1:10
		% init with zeros the datasets, later this extra line
		%  will be removed but we need it to append the data correctly
		TrainData = zeros(1,9);
		TrainLabels=zeros(1,1);
		TestData=zeros(1,9);
		TestLabels=zeros(1,1);
		
		% one fold will be used as test
		%  and the rest of them will be joined and used as train
		for j=1:10
			if i~=j
				TrainData = [TrainData ; TenFoldData(:,:,j)];
				TrainLabels = [TrainLabels ; TenFoldLabels(:,j)];
			else
				TestData = TenFoldData(:,:,j);
				TestLabels = TenFoldLabels(:,j);
			end
		end
		
		% appending the datasets is done trim the lines with zeros
		%  some of those lines may be from folds having 
		%  1 less or extra row in them
		TrainData(~any(TrainData,2), : )=[];
		TrainLabels(~any(TrainLabels,2), : )=[];
		TestData(~any(TestData,2), : )=[];
		TestLabels(~any(TestLabels,2), : )=[];
		
		% run k-means
		[Algo_TestLabels] = myWeightedKnn(TestData, TrainData, TrainLabels, k) ;
		% make the confusion matrix
		[Confusion_Matrix] = make_conf_matrix(TestLabels, Algo_TestLabels);
		
		% sum the cunfision matrix results
		Confusion_Matrix_w1= Confusion_Matrix_w1+ Confusion_Matrix;
	end
	% calculate results
	Sensitivity(1,2)=Confusion_Matrix_w1(1,1)/( Confusion_Matrix_w1(1,1)+Confusion_Matrix_w1(2,1) );
	Specificity(1,2)=Confusion_Matrix_w1(2,2)/( Confusion_Matrix_w1(1,2)+Confusion_Matrix_w1(2,2) );
	Accuracy(1,2)=( Confusion_Matrix_w1(1,1)+Confusion_Matrix_w1(2,2) )/sum(sum(Confusion_Matrix_w1)) ;
	
	%%%		  		     %%%
	%% Train 66% Test 34% %%
	%%%				     %%%
	disp('Running 66%-34%');
	
	% split the dataset by 66% for train and 34% for test
	[TrainData,TrainLabels,TestData,TestLabels] = train66_test34(Dataset);
	% run k-means
	[Algo_TestLabels] = myWeightedKnn(TestData, TrainData, TrainLabels, k) ;
	% make the confusion matrix
	[Confusion_Matrix_w2] = make_conf_matrix(TestLabels, Algo_TestLabels);
	% calculate results
	Sensitivity(2,2)=Confusion_Matrix_w2(1,1)/( Confusion_Matrix_w2(1,1)+Confusion_Matrix_w2(2,1) );
	Specificity(2,2)=Confusion_Matrix_w2(2,2)/( Confusion_Matrix_w2(1,2)+Confusion_Matrix_w2(2,2) );
	Accuracy(2,2)=( Confusion_Matrix_w2(1,1)+Confusion_Matrix_w2(2,2) )/sum(sum(Confusion_Matrix_w2)) ;
	
	%%%				%%%
	%% Leave one out %%
	%%%				%%%
	disp('Running leave one out')
	
	% int. confusion matrix with zeros
	Confusion_Matrix_w3= zeros(2);
	% repeat for each row in dataset
	datanum = size(Dataset,1);
	for i=1:datanum
		
		% keep the dataset to a temporary dataset
		temp_TrainDataset = Dataset(:,[1:9]);
		temp_TrainLabels = Dataset(:,10);
		% and remove the row we will use for test
		temp_TrainDataset(i,:) = [];
		temp_TrainLabels(i,:) = [];
		
		% run k-means
		[Algo_TestLabels] = myWeightedKnn(Dataset(i,[1:9]), temp_TrainDataset, temp_TrainLabels, k) ;
		% make the confusion matrix
		[Confusion_Matrix] = make_conf_matrix(Dataset(i,10), Algo_TestLabels);
		
		% sum the cunfision matrix results
		Confusion_Matrix_w3 = Confusion_Matrix_w3+Confusion_Matrix;
	end
	% calculate results
	Sensitivity(3,2)=Confusion_Matrix_w3(1,1)/( Confusion_Matrix_w3(1,1)+Confusion_Matrix_w3(2,1) );
	Specificity(3,2)=Confusion_Matrix_w3(2,2)/( Confusion_Matrix_w3(1,2)+Confusion_Matrix_w3(2,2) );
	Accuracy(3,2)=( Confusion_Matrix_w3(1,1)+Confusion_Matrix_w3(2,2) )/sum(sum(Confusion_Matrix_w3)) ;
	Sensitivity(3,2)
	Specificity(3,2)
	Accuracy(3,2)
	
	% clear messages to display results
	clc
	disp('Simple k-Means');
	disp('1. 10 fold cross validation Confusion Matrix :');
	disp(Confusion_Matrix_1);
	disp(['Sensitivity : ',num2str(Sensitivity(1,1))]);
	disp(['Specificity : ',num2str(Specificity(1,1))])
	disp(['Accuracy : ',num2str(Accuracy(1,1))])
	disp('-------------');
	disp('2. 66% - 34% Confusion Matrix :');
	disp(Confusion_Matrix_2);
	disp(['Sensitivity : ',num2str(Sensitivity(2,1))])
	disp(['Specificity : ',num2str(Specificity(2,1))])
	disp(['Accuracy : ',num2str(Accuracy(2,1))])
	disp('-------------');
	disp('3. Leave one out Confusion Matrix :');
	disp(Confusion_Matrix_3);
	disp(['Sensitivity : ',num2str(Sensitivity(3,1))])
	disp(['Specificity : ',num2str(Specificity(3,1))])
	disp(['Accuracy : ',num2str(Accuracy(3,1))])
	disp('---------------------------------------------');
	disp(' ');
	disp('Weighted k-Means');
	disp('1. 10 fold cross validation Confusion Matrix :');
	disp(Confusion_Matrix_w1);
	disp(['Sensitivity : ',num2str(Sensitivity(1,2))])
	disp(['Specificity : ',num2str(Specificity(1,2))])
	disp(['Accuracy : ',num2str(Accuracy(1,2))])
	disp('-------------');
	disp('2. 66% - 34% Confusion Matrix :');
	disp(Confusion_Matrix_w2);
	disp(['Sensitivity : ',num2str(Sensitivity(2,2))])
	disp(['Specificity : ',num2str(Specificity(2,2))])
	disp(['Accuracy : ',num2str(Accuracy(2,2))])
	disp('-------------');
	disp('3. Leave one out Confusion Matrix :');
	disp(Confusion_Matrix_w3);
	disp(['Sensitivity : ',num2str(Sensitivity(3,2))])
	disp(['Specificity : ',num2str(Specificity(3,2))])
	disp(['Accuracy : ',num2str(Accuracy(3,2))])

	% plot execution time per k
	figure;
	plot([1:15],time);
	title('Execution time per k');
	xlabel('k value');
	ylabel('execution time');
	% plot accuracy per k
	figure;
	plot([1:15],acc);
	title('Accuracy time per k');
	xlabel('k value');
	ylabel('Accuracy');
	
end


% Function to read a file "data.txt" and return a marix "Dataset" with 
% the relative data to our exercise
function [Dataset] = read_file(file_name)
	% matrix initialization
    Data=zeros(1,11);
	Dataset=zeros(1,10);
	
	% check if the file exist in our directory
    if exist(file_name , 'file')
		% start a counter for the dataset row index
		i=1;
		% open file and keep it's file id
        fileID = fopen(file_name);
		
		% untill we reach the end of file
		while ~feof(fileID)
			% read and save each line to data
			Data = fscanf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',[1,11]);
			% record the line to the final dataset
			Dataset(i,:)=Data(1,2:11);
			% increase dataset's row index
			i=i+1;
		end
		
		% close file
		fclose(fileID);
    end
	
end
%end of function read_file()



% Function to seperate our Dataset to TrainDataset and TestDataset
% with their labels using the 66% for train and 34% for test
function [TrainData,TrainLabels,TestData,TestLabels] = train66_test34(Dataset)
	% get the number of rows of our Dataset
	datanum = size(Dataset,1);
	% get the number of data we will use for train (66%)
	trainnum = round( (datanum*66) / 100 );
	% get the number of data we will use for test (34%)
	testnum = datanum - trainnum;
	
	% get randomly the indexes of the test data
	% randperm returns 1 x testnum array of unique integers ranging 
	% from 1 to datanum
	test_data_index = randperm(datanum,testnum);
	% sort the random indexes in ascending order
	% this will help eliminating the rows from the Dataset later
	% without effecting their index too much
	test_data_index = sort(test_data_index,'ascend');

	%for each test registry
	for i=1:testnum
		%since we remove a row in every loop, and the next index is always
		%more than the last, we simply need to remove from each the number
		%of loops we had so far to have it point to the correct row
		test_row_index = test_data_index(i) - i +1;

		%get the data from dataset
		TestData(i,:) = Dataset(test_row_index,1:9);
		%get the class from dataset
		TestLabels(i,1) = Dataset(test_row_index,10);
		
		%remove the row from our Dataset, this wont effect the Dataset
		%outside this function
		Dataset(test_row_index,:)=[];
	end

	%the train data and their labels are now the current Dataset
	%so we get the data
	TrainData = Dataset(:,1:9);
	%and their labels
	TrainLabels = Dataset(:,10);
end
%end of function train66_test34()



% Function to seperate our Dataset to 10 folds and their labels
% for the 10 fold cross validation. All the folds will be included in a
% 3 dimentional marix (Mx9x10) with the 3rd dimention pointing to each fold
function [TenFoldData,TenFoldLabels] = TenFoldCrossValidation(Dataset)
	% get the number of rows of our Dataset
	datanum = size(Dataset,1);
	% get the number of rows in each of the 10 folds
	minidatanum = ceil( datanum/10 );
	% initialize the folds and their labels with zeros
	% dividing the total with 10 may not give the same number for each
	% fold so we will use the zeros later for control
	TenFoldData = zeros(minidatanum,9,10);
	TenFoldLabels = zeros(minidatanum,10);
	
	% get random indexes to suffle our dataset
	random_indexes = randperm(datanum);
	% suffle the dataset's rows to add randomness to our folds
	Dataset = Dataset(random_indexes,:);
	
	% sort the Dataset based on their class
	% this will keep the dataset suffled 
	% for the rest of it's columns
	[X,order]=sort(Dataset(:,10));
	Dataset_sorted = Dataset(order,:);
	
	% initialize counters for the loop
	row=1;
	miniset_counter=1;
	% we pass the registries in the ordered dataset to each of the 
	% folds. Since the dataset we use is ordered, in the end of this loop
	% they will have the same distribution as the original one.
	for i=1:datanum
		% give the registry to the fold matrix and it's label
		TenFoldData(row,:,miniset_counter) = Dataset_sorted(i,1:9);
		TenFoldLabels(row,miniset_counter) = Dataset_sorted(i,10);

		% if we have pass one registry for each fold in this row
		% continue to the next row and start from the first fold again
		% else, continue to the next fold for the same row
		if miniset_counter==10
			miniset_counter=1;
			row=row+1;
		else
			miniset_counter=miniset_counter+1;
		end
	end
	% at the end of the loop, we will have the folds and their labels
	% with similar destribution to the original dataset.
	% there is a possibility that one or more folds will have an extra line
	% but for the rest of them this extra line is filled with zeros so we can control it later.

end
%end of function TenFoldCrossValidation()


% Function to simulate k means on a dataset similar to the one
% give in this exercise. 
function [TestLabels] = mykNN(TestData, TrainData, Labels, k) 
	% if the centers move less than dc, stop the loop
	% after some experimentation a value of 3 seems to finish the
	%  simulation in realistic time, any lower than that 
	%  and the simulation takes too long
	dc=3;
	% get the number of rows of our Train Dataset
	traindatanum = size(TrainData,1);
	% get the number of rows of our Test Dataset
	testdatanum = size(TestData,1);
	
	% init. a distance matrix with -1
	distance = ones(traindatanum,k);
	distance = -1*distance;
	
	% start with random centers (for now)
	centers = randi(10,k,9);
	% init. a temp centers matrix with -1
	% we will use this to notice any changes to our centers
	% and stop the training when there is none
	temp_centers = ones(k,9);
	temp_centers = -1*temp_centers;
	% init. the group of each point with zeros
	% this will keep a value from 1 to k pointing 
	% at which group each point belongs to
	groups = zeros(traindatanum,1);
	
	loop_flag =0;
	while loop_flag == 0
		if ( temp_centers <= (centers +dc) ) & ( temp_centers >= (centers -dc) )
			% if the centers haven't move
			% end the training loop
			loop_flag = 1;
		else
			% keep the centers before any change
			temp_centers = centers;
			% reinit. the centers with zeros so we can calculate in this matrix
			% the moved centers. We will use the temp_centers for our calculation
			% in this loop
			centers = zeros(k,9);
			
			% find the distance of each point from each center
			% and assign the point to the nearest center's group
			for i=1:traindatanum
				% init. a minimum with a very large number
				min=inf();
				
				for j=1:k
					% calculate the euclidean distance, we use temp_centers since the actual centers
					% will be recalculated in the process to avoid multiple loops
					distance(i,j) = sqrt(  sum( (TrainData(i,:)-temp_centers(j,:)).^2 ) );
					
					% if the distance from this center is the smaller for this point
					% add this point to the center's group and update the min
					% this will be updated for each center leaving at the end the correct group
					if min > distance(i,j)
						groups(i) = j;
						min = distance(i,j);
					end
				end
				
				% calculate the new center of this group as the mean of the points values
				centers(groups(i),:) = ( centers(groups(i),:) + TrainData(i,:) ) ./ 2;
			end
		end
	end
	% at the end of this loop we have place each point in our train data to a group
	% and the centers wont move any more
	
	% init. the label of each center's group to zero
	group_labels=zeros(k,1);
	% init the group's amount of points to zero
	group_counter=zeros(k,2);
	
	% each point votes for the label of it's group
	for i=1:traindatanum
		if Labels(i)==2
			group_counter(groups(i),1) = group_counter(groups(i),1)+1;
		else
			group_counter(groups(i),2) = group_counter(groups(i),2)+1;
		end
	end
	% check for each group which label has more votes and
	%  use it as the group's label
	for i=1:k
		if group_counter(i,1) > group_counter(i,2)
			group_labels(i) = 2;
		else
			group_labels(i) = 4;
		end
	end
	
	%%%%														%%%%
	%% at this point the training is complete and the test begins %%
	%%%%														%%%%
	
	% this loop will give us the testlabel for each testdata row
	for i=1:testdatanum
		% init. the distance of the test data row from each center to zeros
		test_distance = zeros(k,1);
		% init. a minimum with a very large number
		min=inf();
		% init. the test_group of this point to zero
		test_group=0;
		
		% find which center is closer to this test point
		for j=1:k
			% calculate the euclidean distance of the test point from each center
			test_distance(j) = sqrt(  sum( (TestData(i,:)-centers(j,:)).^2 ) );
			
			% if this center is closer to the test point, correct our vars
			if min > test_distance(j)
				test_group = j;
				min = test_distance(j);
			end
		end
		
		% give this test point the label of the group
		% which has it's center closer to it
		TestLabels(i) = group_labels(test_group);
	end
	
end
%end of function mykNN()


% Function to create and return a confusion matrix give the real testlabels
% and the testlabels returned by the simulation
function [Confusion_Matrix] = make_conf_matrix(Real_TestLabels, Algo_TestLabels);
	% get the number of rows of our Test Labes
	labelsnum = size(Real_TestLabels,1);
	% init. the confusion matrix with zeros
	Confusion_Matrix = zeros(2);
	
	for i=1:labelsnum
		if Real_TestLabels(i) == 2
			if Algo_TestLabels(i) == 2
				% True Positive, Real_TestLabels=2 & Algo_TestLabels=2
				Confusion_Matrix(1,1) = Confusion_Matrix(1,1) +1;
			else
				% False Negative, Real_TestLabels=2 & Algo_TestLabels=4
				Confusion_Matrix(2,1) = Confusion_Matrix(2,1) +1;
			end
		else
			if Algo_TestLabels(i) == 2
				% False Positive, Real_TestLabels=4 & Algo_TestLabels=2
				Confusion_Matrix(1,2) = Confusion_Matrix(1,2) +1;
			else
				% True Negative, Real_TestLabels=4 & Algo_TestLabels=4
				Confusion_Matrix(2,2) = Confusion_Matrix(2,2) +1;
			end
		end
	end
	
end
%end of function make_conf_matrix()




% Function to simulate k means on a dataset similar to the one
% give in this exercise. 
function [TestLabels] = myWeightedKnn(TestData, TrainData, Labels, k) 
	% if the centers move less than dc, stop the loop
	% after some experimentation a value of 3 seems to finish the
	%  simulation in realistic time, any lower than that 
	%  and the simulation takes too long
	dc=3;
	% get the number of rows of our Train Dataset
	traindatanum = size(TrainData,1);
	% get the number of rows of our Test Dataset
	testdatanum = size(TestData,1);
	
	% init. a distance matrix with -1
	distance = ones(traindatanum,k);
	distance = -1*distance;
	
	% minmax_dist will keep for each center in the first column the distance
	%  of the closest point and the 2nd column the distance
	%  of the furthest point in it's group
	minmax_dist(:,1)=inf(k,1);
	minmax_dist(:,2)=-1*ones(k,1);
	
	% start with random centers (for now)
	centers = randi(10,k,9);
	% init. a temp centers matrix with -1
	% we will use this to notice any changes to our centers
	% and stop the training when there is none
	temp_centers = ones(k,9);
	temp_centers = -1*temp_centers;
	% init. the group of each point with zeros
	% this will keep a value from 1 to k pointing 
	% at which group each point belongs to
	groups = zeros(traindatanum,1);
	
	loop_flag =0;
	while loop_flag == 0
		if ( temp_centers <= (centers +dc) ) & ( temp_centers >= (centers -dc) )
			% if the centers haven't move
			% end the training loop
			loop_flag = 1;
		else
			% keep the centers before any change
			temp_centers = centers;
			% reinit. the centers with zeros so we can calculate in this matrix
			% the moved centers. We will use the temp_centers for our calculation
			% in this loop
			centers = zeros(k,9);
			
			% find the distance of each point from each center
			% and assign the point to the nearest center's group
			for i=1:traindatanum
				% init. a minimum with a very large number
				min=inf();
				% init. a maximum with a negative number
				max = -1;
				
				for j=1:k
					% calculate the euclidean distance, we use temp_centers since the actual centers
					% will be recalculated in the process to avoid multiple loops
					distance(i,j) = sqrt(  sum( (TrainData(i,:)-temp_centers(j,:)).^2 ) );
					
					% if the distance from this center is the smaller for this point
					% add this point to the center's group and update the min
					% this will be updated for each center leaving at the end the correct group
					if min > distance(i,j)
						groups(i) = j;
						min = distance(i,j);
					end
					% for the weighted k-means we will also need to keep the max
					if max < distance(i,j)
						max = distance(i,j);
					end
				end
				
				% get the min and max distance for this center
				% values we will later use for the weight
				if minmax_dist(groups(i),1) > min
					minmax_dist(groups(i),1) = min;
				end
				if minmax_dist(groups(i),2) < max
					minmax_dist(groups(i),2) = max;
				end
				
				% calculate the new center of this group as the mean of the points values
				centers(groups(i),:) = ( centers(groups(i),:) + TrainData(i,:) ) ./ 2;
			end
		end
	end
	% at the end of this loop we have place each point in our train data to a group
	% and the centers wont move any more
	
	% init. the label of each center's group to zero
	group_labels=zeros(k,1);
	% init the group's amount of points to zero
	group_counter=zeros(k,2);
	
	% each point votes for the label of it's group
	% we also take notice of the weight of each vote this time
	for i=1:traindatanum
		weight = ( minmax_dist(groups(i) , 2) - distance(i,groups(i)) ) / ( minmax_dist(groups(i) , 2) - minmax_dist(groups(i) , 1) ) ;
		if Labels(i)==2
			group_counter(groups(i),1) = group_counter(groups(i),1)+weight;
		else
			group_counter(groups(i),2) = group_counter(groups(i),2)+weight;
		end
	end
	% check for each group which label has more votes and
	%  use it as the group's label
	for i=1:k
		if group_counter(i,1) > group_counter(i,2)
			group_labels(i) = 2;
		else
			group_labels(i) = 4;
		end
	end
	
	%%%%														%%%%
	%% at this point the training is complete and the test begins %%
	%%%%														%%%%
	
	% this loop will give us the testlabel for each testdata row
	for i=1:testdatanum
		% init. the distance of the test data row from each center to zeros
		test_distance = zeros(k,1);
		% init. a minimum with a very large number
		min=inf();
		% init. the test_group of this point to zero
		test_group=0;
		
		% find which center is closer to this test point
		for j=1:k
			% calculate the euclidean distance of the test point from each center
			test_distance(j) = sqrt(  sum( (TestData(i,:)-centers(j,:)).^2 ) );
			
			% if this center is closer to the test point, correct our vars
			if min > test_distance(j)
				test_group = j;
				min = test_distance(j);
			end
		end
		
		% give this test point the label of the group
		% which has it's center closer to it
		TestLabels(i) = group_labels(test_group);
	end
	
end
%end of function myWeightedKnn()
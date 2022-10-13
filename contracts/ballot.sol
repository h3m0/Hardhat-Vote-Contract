// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Ballot{ 	

	address payable public currentLeader;
	uint256 internal Ccount;
	uint256 internal Vcount;
	Candidate[] public candidates;
	Voter[] public voters;
	uint256 internal immutable Efee;
	mapping(address => uint256) public voterToId;		
	mapping(address => Voter) public voteraddrtoData;
	mapping(address => Candidate) public candidateaddrtoData;
	mapping(address => address) public voteraddrToCandidateaddr;	
	mapping(address => Candidate) public voterToCandidate;

	modifier onlyCurrentLeader{
		require(msg.sender == currentLeader, "Only the current leader can call this function!");
		_;
	}

	enum State { OPEN, CLOSED }
	State internal currentState; 

	constructor() {
		currentLeader = payable(msg.sender);		
		Efee = 1 ether;
		currentState = State.CLOSED;
	}

	struct Voter{
		string name;
		uint age;
		bool hasVoted;
		uint count;	
		address Vaddress;
		bool isVoter;
	}

	struct Candidate{
		string name;		
		uint age;		
		uint256 votes;
		uint256 count;
		address Caddress;
		bool isCandidate;
	}		

	function becomeCandidate(
		string memory _name,		
		uint256 _age 		
	) payable public returns(string memory){
		require(msg.value >= Efee, "You need to spend more ETH");
		require(candidateaddrtoData[msg.sender].isCandidate != true, "You are already a candidate");
		require(_age >= 35, "You are too young to be the leader");
		Candidate memory aspirant = Candidate(
			{
				name: _name,			   
			    age: _age,			    	   
			    votes: 0,
			    count: Ccount,
			    isCandidate: true,
			    Caddress: msg.sender
			}
		);
		address payable This = payable(address(this));
		This.transfer(msg.value);
		candidates.push(aspirant);		
		candidateaddrtoData[msg.sender] = aspirant;			
		Ccount++;
		return string(abi.encodePacked("Your Candidate Number is: ", Ccount));			
	}

	function register(		
		string memory _name,		
		uint256 _age,
		uint256 _ID 		
	) public returns(string memory){		
		require(msg.sender != currentLeader, "The current leader cannot vote");
		require(voteraddrtoData[msg.sender].isVoter != true, "You have already registered");
		require(_age >= 18, "You are too young to vote");		
		Voter memory voter = Voter(
			{
				name: _name,				
				age: _age, 				
				hasVoted: false,			
				count: Vcount,
				isVoter: true,
				Vaddress: msg.sender		
			}
		);	  
		voters.push(voter);	
		voteraddrtoData[msg.sender] = voter;		
		voterToId[msg.sender] = _ID;
		Vcount++;
		return string(abi.encodePacked("Your Voter's No is: ", Vcount));
	}		

	function vote(
		uint256 _vindex, 
		uint256 _index, 
		uint256 _Id
	) public{	
		require(_index <= Ccount, "Invalid Candidate number!");
		require(currentState == State.OPEN, "Can't vote yet");
		require(_Id == voterToId[msg.sender], "Invalid Id");
		require(_vindex <= Vcount, "Invalid Voter number!");	
		require(voters[_vindex - 1].hasVoted != true, "You have already voted");			
		(candidates[_index - 1].votes)++;
		voters[_vindex - 1].hasVoted = true;
		voteraddrToCandidateaddr[msg.sender] = candidates[_index - 1].Caddress;			
		voterToCandidate[msg.sender] = candidates[_index - 1];
	}

	 function checkWinner() view public returns(uint){
	 	uint king;
	 	uint winningP;	 	
	 	for(uint i = 0; i < candidates.length; i++){	 		
	 		if(candidates[i].votes > king){
	 			king = candidates[i].votes;	
	 			winningP = i;
	 		}	    
	 	}	 	
	 	return winningP;
	 }

	 function startElection() onlyCurrentLeader public {
	 	currentState = State.OPEN;
	 }
	 

	function endElection() public onlyCurrentLeader returns(string memory) {
		currentState = State.CLOSED;
		currentLeader = payable(candidates[checkWinner()].Caddress);
		return string(abi.encodePacked(candidates[checkWinner()].name, " won the election!"));		
	}
}

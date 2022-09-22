// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
// 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
// 1440000000000000000


contract Ballot is VRFConsumerBase{ 	

		address payable public currentLeader;
		AggregatorV3Interface internal priceFeed;
		uint256 internal Ccount;
		uint256 internal Vcount;
		bytes32 keyhash;
		uint256 fee;	
		uint256 internal randomResult;
		Candidate[] public candidates;
		Voter[] public voters; 
		uint256 public fee;	
		mapping(address => bytes32) public voterToId;		
		mapping(address => Voter) public voteraddrtoData;
		mapping(address => Candidate) public candidateaddrtoData;
		mapping(address => address) public voteraddrToCandidateaddr;	
		mapping(address => Candidate) public voterToCandidate;

	modifier onlyCurrentleader{
		require(msg.sender == currentLeader,"Only the current leader can call this function!");
		_;
	}

	constructor(
		address _addr,
		address _link,
		address _vrf,
	    bytes32 _keyhash,
	    uint256 fee,
	) VRFConsumerBase(_vrf,,_link){
		currentLeader = payable(msg.sender);
		priceFeed = AggregatorV3Interface(_addr);
		Efee = 1000000;
		fee = _fee;
		keyhash = _keyhash;
	}

	struct Voter{
		string name;
		uint age;
		bool isCitizen;	
		uint yearsInJail;	 
		bool hasVoted;
		uint count;	
		address Vaddress;
		uint256 count2;
	}

	struct Candidate{
		string name;
		uint yearsInJail;
		uint age;
		bool isCitizen;	
		uint256 votes;
		uint256 count;
		address Caddress;
		uint256 count2;
	}		

	// function ETHtoNAIRA(uint256 _eth) public view returns(uint256){
	// 	  (,int256 answer,,,) = priceFeed.latestRoundData();    	  
	// 	  uint256 convertedeth = _eth * (uint256(answer) / 10 ** 8) * 600;
	// 	  return convertedeth;
	// }

	function becomeCandidate(
		string memory _name,
		uint256 _yearsInJail,
		uint256 _age, 
		bool _isCitizen
	) payable public returns(uint256){
		// require(ETHtoNAIRA(msg.value) >= Efee, "You need to spend more ETH");
		require(candidateaddrtoData[msg.sender].count2 < 1, "You are already a candidate");
		require(_yearsInJail <= 3, "Sorry, you have spent too many years in jail");
		require(_isCitizen == true, "Only citizens can be leader");
		require(_age >= 35, "You are too young to be the leader");
		Candidate memory aspirant = Candidate(
			{
				name: _name,
			    yearsInJail: _yearsInJail,
			    age: _age,
			    isCitizen: _isCitizen,		   
			    votes: 0,
			    count: Ccount,
			    count2: 1,
			    Caddress: msg.sender
			}
		);
		currentLeader.transfer(msg.value);
		candidates.push(aspirant);		
		candidateaddrtoData[msg.sender] = aspirant;			
		Ccount++;	
		return Ccount;
	}

	function register(
		string memory _name,
		uint256 _yearsInJail,
		uint256 _age, 
		bool _isCitizen
	) public returns(uint256, bytes32){		
		require(msg.sender != currentLeader, "The current leader cannot vote");
		require(voteraddrtoData[msg.sender].count2 < 1, "You have already registered");
		require(_yearsInJail <= 3, "Sorry, you have spent too many years in jail");
		require(_isCitizen == true, "Only citizens can vote");
		require(_age >= 18, "You are too young to vote");
		Voter memory voter = Voter(
			{
				name: _name,
				yearsInJail: _yearsInJail,
				age: _age, 
				isCitizen: _isCitizen,
				hasVoted: false,			
				count: Vcount,
				count2: 1,
				Vaddress: msg.sender		
			}
		);	  
		voters.push(voter);	
		voteraddrtoData[msg.sender] = voter;
		requestRandomness(keyhash, fee);
		voterToId[msg.sender] = randomResult;
		Vcount++;
		return (Vcount, randomResult);
	}		

	function vote(
		uint256 _vindex, 
		uint256 _index, 
		bytes32 _Id
	) public{	
		require(_index <= Ccount, "Invalid Candidate number!");
		require(_Id == voterToId[msg.sender], "Invalid Id");
		require(_vindex <= Vcount, "Invalid Voter number!");	
		require(voters[_vindex - 1].hasVoted != true, "You have already voted");			
		(candidates[_index - 1].votes)++;
		voters[_vindex - 1].hasVoted = true;
		voteraddrToCandidateaddr[msg.sender] = candidates[_index - 1].Caddress;			
		voterToCandidate[msg.sender] = candidates[_index - 1];
	}

	function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal virtual override{
		randomResult = _randomness;
	}

	 function checkWinner() public onlyCurrentleader returns(uint){
	 	uint king;
	 	uint winningP;
	 	for(uint i = 0; i < candidates.length; i++){	 		
	 		if(candidates[i].votes > king){
	 			king = candidates[i].votes;	
	 			winningP = i;
	 		}	    
	 	}	 	
	 	return winningP
	 }

	 function revealWinner() return(string memory){
	 	return candidates[checkWinner()].name;
	 }
}


// I want to share with you all a smart contract that allows you to book and leave hotel rooms. It is a modified version of the Dapp University solidity tutorial that i thought  of to really challenge myself.  It allows users to systematically book and leave room. There is also a new hotel function that allows you to add a new custom hotel room. I plan to make this a full web app when I finish learning on Mr Patrick's blockchain dev(java script) course. I am open to criticism and corrections. Special thanks to Dapp University, Mr Patrick Collins and  freeCodeCamp. 

// freecodecamp

//  https://www.youtube.com/watch?v=gyMwXuJrbJQ&t=19294s

// Dapp university 

// https://www.youtube.com/watch?v=nORC_s2HzAg



// #freecodecamp #DappUniversity #Solidiy #Smartcontracts #ethereumblockchain #javascript #share #blockchain #learning 


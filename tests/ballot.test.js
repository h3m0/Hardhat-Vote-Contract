const { getNamedAccounts, deployments, ethers } = require('hardhat')
const { expect, assert } = require('chai');
let BALLOT;
const value = ethers.utils.parseEther("1");


describe(
	"Ballot Contract", async () => {
		beforeEach(
			async () => {
				const { deployer } = await getNamedAccounts();
				BALLOT = await ethers.getContract("Ballot");
			}
		)

		it(
			"Should register a voter properly", async () => {
				const testers = await ethers.getSigners();
				const tester = testers[2];
				await BALLOT.connect(tester).register("name", 17, "64038035705")
			}
		)

		it(
			"Should revert if voter votes improperly", async () => {
				const testers = await ethers.getSigners();
				const tester = testers[2];
				expect(await BALLOT.connect(tester).vote(1, 1, "64038035705")).to.be.reverted;
			}
		)

		it(
			"Should revert if candidate pays little", async () => {
				const testers = await ethers.getSigners();
				const tester = testers[3];
				expect(await BALLOT.connect(tester).becomeCandidate("hasbi", 45)).to.be.reverted;
			}
		)

		it(
			"Should register a candidate well", async () => {
				const testers = await ethers.getSigners();
				const tester = testers[3];
				await BALLOT.connect(tester).becomeCandidate("basit", 45, {value:value});
			}
		)

		it(
			"Should assign Winner well", async () => {
				const { deployer } = await getNamedAccounts();				
				await BALLOT.endElection({from: deployer});
			}
		)
		
	}
)

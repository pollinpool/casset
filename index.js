const Web3 = require('web3');
const fs = require('fs');
const web3 = new Web3('https://bsc-dataseed.binance.org/');

const governanceTokenAbi = JSON.parse(fs.readFileSync('GovernanceToken.json'));
const fundGovernanceAbi = JSON.parse(fs.readFileSync('FundGovernance.json'));

const governanceTokenAddress = '0xYourGovernanceTokenAddress';
const fundGovernanceAddress = '0xYourFundGovernanceAddress';

const governanceToken = new web3.eth.Contract(governanceTokenAbi, governanceTokenAddress);
const fundGovernance = new web3.eth.Contract(fundGovernanceAbi, fundGovernanceAddress);

async function createProposal(description, altcoins, allocations, fromAddress, privateKey) {
    const data = fundGovernance.methods.createProposal(description, altcoins, allocations).encodeABI();

    const tx = {
        to: fundGovernanceAddress,
        data,
        gas: 2000000
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);

    await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log('Proposal created');
}

async function vote(proposalId, support, fromAddress, privateKey) {
    const data = fundGovernance.methods.vote(proposalId, support).encodeABI();

    const tx = {
        to: fundGovernanceAddress,
        data,
        gas: 2000000
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);

    await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log('Vote casted');
}

async function executeProposal(proposalId, fromAddress, privateKey) {
    const data = fundGovernance.methods.executeProposal(proposalId).encodeABI();

    const tx = {
        to: fundGovernanceAddress,
        data,
        gas: 2000000
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);

    await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log('Proposal executed');
}
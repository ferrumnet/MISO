certoraRun spec/harness/DutchAuctionHarness.sol:DutchAuctionHarness spec/harness/DummyERC20A.sol:DummyERC20A \
spec/harness/DummyERC20B.sol:DummyERC20B spec/harness/DummyWeth.sol:DummyWeth spec/harness/Receiver.sol:Receiver spec/harness/Wallet.sol:Wallet \
	--verify DutchAuctionHarness:spec/dutchAuction.spec \
	--link DutchAuctionHarness:wallet=Wallet \
	--settings -assumeUnwindCond,-ignoreViewFunctions,-enableStorageAnalysis=true \
	--solc solc6.12 \
	--rule $1 \
	--cache dutchAuction \
	--staging --msg "dutch auction : $1 - $2"
import hre, { ethers } from "hardhat";

export async function deploySmartContracts(options: {
  token: {
    name: string,
    symbol: string,
  },
  tracking: boolean,
  showOutput: boolean,
  verify: boolean,
}) {
  const { token, tracking, showOutput, verify } = options;

  const tasks: Array<() => Promise<void>> = [];
  const Token = await deployToken(token.name, token.symbol);
  const TokenAddress = await Token.getAddress();

  showOutput && console.log("Token deployed to:", TokenAddress);

  if (tracking) {
    const Tracking = await deployTracking(TokenAddress);
    const TrackingAddress = await Tracking.getAddress();

    showOutput && console.log("Tracking deployed to:", TrackingAddress);

    await Token.approve(await Tracking.owner(), ethers.MaxUint256);

    verify && tasks.push(() => {
      return hre.run("verify:verify", {
        address: TrackingAddress,
        constructorArguments: [TokenAddress],
      })
    });
  }

  verify && tasks.push(() => {
    return hre.run("verify:verify", {
      address: TokenAddress,
      constructorArguments: [token.name, token.symbol],
    });
  });

  tasks.length && await Promise.allSettled(tasks.map(task => task()));
}

async function deployToken(name: string, symbol: string) {
  const TokenFactory = await ethers.getContractFactory("Token");
  const Token = await TokenFactory.deploy(name, symbol);

  await Token.waitForDeployment();

  return Token;
}

async function deployTracking(tokenAddress: string) {
  const TrackingFactory = await ethers.getContractFactory("Tracking");
  const Tracking = await TrackingFactory.deploy(tokenAddress);

  await Tracking.waitForDeployment();

  return Tracking;
}
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import 'dotenv/config';

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    mumbai: {
      url: process.env.POLYGON_MUMBAI_URL,
      accounts: [process.env.METAMASK_PRIVATE_KEY ?? ''],
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGON_MUMBAI_ETHERSCAN_API_KEY ?? '',
    }
  }
};

export default config;

import { deploySmartContracts } from "../utils";

deploySmartContracts({
  token: {
    name: "InnovaTkn",
    symbol: "INN",
  },
  tracking: true,
  showOutput: true,
  verify: true,
}).catch((error) => {
  console.error(error);
}).finally(() => {
  process.exit();
});

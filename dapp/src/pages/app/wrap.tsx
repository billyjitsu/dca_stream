import Head from "next/head";
import WormholeBridge, {
  type WormholeConnectConfig,
} from "@wormhole-foundation/wormhole-connect";
import { Layout } from "~/components/layout";

export default function Bridge() {
  const config: WormholeConnectConfig = {
    env: "testnet",
    networks: ["goerli", "mumbai"],
    tokens: ["ETH", "WETH", "MATIC", "WMATIC"],
    mode: "dark",
    pageHeader: "Bridge",
    showHamburgerMenu: false,
  };

  return (
    <Layout className="max-h-screen overflow-hidden">
      <Head>
        <title>Create T3 App</title>
        <meta name="description" content="Generated by create-t3-app" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <main className="flex h-full flex-col items-center justify-center overflow-y-hidden">
        wrap
      </main>
    </Layout>
  );
}

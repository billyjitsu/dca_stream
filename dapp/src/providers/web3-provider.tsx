"use client";

import {
  RainbowKitProvider,
  getDefaultWallets,
  connectorsForWallets,
} from "@rainbow-me/rainbowkit";
import { configureChains, createConfig, WagmiConfig } from "wagmi";
import { goerli } from "wagmi/chains";
import { publicProvider } from "wagmi/providers/public";
import { RainbowKitSiweNextAuthProvider } from "@rainbow-me/rainbowkit-siwe-next-auth";
import { type ReactNode, useEffect, useState } from "react";

const { chains, publicClient, webSocketPublicClient } = configureChains(
  [goerli],
  [publicProvider()],
);

const projectId = "56c13c38a68fe4ebeee285664b642121";

const { wallets } = getDefaultWallets({
  appName: "RainbowKit demo",
  projectId,
  chains,
});

const demoAppInfo = {
  appName: "Rainbowkit Demo",
};

const connectors = connectorsForWallets([...wallets]);

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
  webSocketPublicClient,
});

export function Web3Provider({ children }: { children: ReactNode }) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  return (
    <WagmiConfig config={wagmiConfig}>
      <RainbowKitSiweNextAuthProvider>
        <RainbowKitProvider chains={chains} appInfo={demoAppInfo}>
          {mounted && children}
        </RainbowKitProvider>
      </RainbowKitSiweNextAuthProvider>
    </WagmiConfig>
  );
}

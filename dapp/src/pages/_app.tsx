import { type Session } from "next-auth";
import { SessionProvider } from "next-auth/react";
import { type AppType } from "next/app";
import "~/styles/globals.css";
import { Inter as FontSans } from "next/font/google";
import { cn } from "~/lib/utils";
import { Layout } from "~/components/layout";
import { ThemeProvider } from "~/providers/theme-provider";
import { Web3Provider } from "~/providers/web3-provider";
import "@rainbow-me/rainbowkit/styles.css";

export const fontSans = FontSans({
  subsets: ["latin"],
  variable: "--font-sans",
});

const MyApp: AppType<{ session: Session | null }> = ({
  Component,
  pageProps: { session, ...pageProps },
}) => {
  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="light"
      enableSystem
      disableTransitionOnChange
    >
      <SessionProvider session={session}>
        <Web3Provider>
          <div
            className={cn(
              "min-w-screen h-full bg-background font-sans antialiased",
              fontSans.variable,
            )}
          >
            <Component {...pageProps} />
          </div>
        </Web3Provider>
      </SessionProvider>
    </ThemeProvider>
  );
};

export default MyApp;

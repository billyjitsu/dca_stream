import { type ReactNode } from "react";
import { Navbar } from "~/components/navbar";
import { Footer } from "~/components/footer";
import { cn } from "~/lib/utils";

interface LayoutProps {
  children: ReactNode;
  className?: string;
}

export function Layout({ children, className }: LayoutProps) {
  return (
    <div
      className={cn(
        "mx-auto min-h-screen max-w-7xl px-6 py-10 lg:px-8 ",
        className,
      )}
    >
      <Navbar />
      {children}
      <Footer />
    </div>
  );
}

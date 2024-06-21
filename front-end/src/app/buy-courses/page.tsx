import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";

export default function Home() {
    return(
        <main className="bg-test bg-cover bg-center">
        <Navbar />
            <h1 className="flex min-h-screen justify-center items-center text-center text-3xl font-bold">Here you can buy the courses by your wallet.</h1>
                <button className="custom-button transition-transform transform hover:scale-125 duration-300">
                    Buy Courses
                </button>
        <Footer />
        </main>
    )
}
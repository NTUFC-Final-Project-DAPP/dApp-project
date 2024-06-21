import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";

export default function Home() {
    return(
        <main className="bg-test bg-cover bg-center flex flex-col min-h-screen justify-center items-center">
            <Navbar />
                <h1 className="text-3xl font-bold">Here you can upload your courses.</h1>
                <button className="custom-button transition-transform transform hover:scale-125 duration-300">
                    Upload Courses
                </button>
        </main>
    )
}
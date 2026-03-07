import { useForm, Link } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

export default function Register() {
  const { data, setData, post, processing, errors } = useForm({
    email_address: "",
    password: "",
    password_confirmation: "",
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    post("/registration")
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-muted/40 px-4">
      <div className="mb-8 text-center">
        <span className="text-sm font-semibold tracking-tight text-foreground">UnderDog Exchange</span>
      </div>

      <Card className="w-full max-w-xs rounded-2xl shadow-sm">
        <CardHeader className="pb-4">
          <CardTitle className="text-xl font-semibold">Create an account</CardTitle>
          <CardDescription className="text-sm">Enter your details to get started.</CardDescription>
        </CardHeader>

        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="email_address">Email</Label>
              <Input
                id="email_address"
                type="email"
                value={data.email_address}
                onChange={(e) => setData("email_address", e.target.value)}
                placeholder="you@example.com"
                autoComplete="email"
                disabled={processing}
                aria-invalid={!!errors.email_address}
                className="h-9 rounded-md text-sm"
              />
              {errors.email_address && (
                <p className="text-xs text-destructive">{errors.email_address}</p>
              )}
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                value={data.password}
                onChange={(e) => setData("password", e.target.value)}
                placeholder="At least 8 characters"
                autoComplete="new-password"
                disabled={processing}
                aria-invalid={!!errors.password}
                className="h-9 rounded-md text-sm"
              />
              {errors.password && (
                <p className="text-xs text-destructive">{errors.password}</p>
              )}
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="password_confirmation">Confirm password</Label>
              <Input
                id="password_confirmation"
                type="password"
                value={data.password_confirmation}
                onChange={(e) => setData("password_confirmation", e.target.value)}
                autoComplete="new-password"
                disabled={processing}
                aria-invalid={!!errors.password_confirmation}
                className="h-9 rounded-md text-sm"
              />
              {errors.password_confirmation && (
                <p className="text-xs text-destructive">{errors.password_confirmation}</p>
              )}
            </div>

            <Button type="submit" className="w-full mt-2" disabled={processing}>
              {processing ? "Creating account…" : "Create account"}
            </Button>
          </form>
        </CardContent>

        <CardFooter className="justify-center">
          <p className="text-sm text-muted-foreground">
            Already have an account?{" "}
            <Link
              href="/session/new"
              className="text-foreground font-medium underline underline-offset-4 hover:no-underline"
            >
              Sign in
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  )
}
